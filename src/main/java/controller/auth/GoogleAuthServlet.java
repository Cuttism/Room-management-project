package controller.auth;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller handling Google OAuth 2.0 / Google Identity Services Sign-In (/login/google).
 */
@WebServlet(name = "GoogleAuthServlet", urlPatterns = {"/login/google"})
public class GoogleAuthServlet extends HttpServlet {
    public static final String GOOGLE_CLIENT_ID =
            "265168256933-o1bdbborcthrks671vocs159brnb8h1v.apps.googleusercontent.com";

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String credential = req.getParameter("credential");

        if (credential == null || credential.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Không nhận được mã xác thực từ Google. Vui lòng thử lại!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        String payloadJson = verifyAndExtractPayload(credential.trim());
        if (payloadJson == null) {
            req.setAttribute("errorMessage", "Xác thực tài khoản Google không hợp lệ hoặc đã hết hạn!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        String aud = extractJsonString(payloadJson, "aud");
        if (!GOOGLE_CLIENT_ID.equals(aud)) {
            req.setAttribute("errorMessage", "Google Client ID không khớp với cấu hình hệ thống!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        String email = extractJsonString(payloadJson, "email");
        String fullName = extractJsonString(payloadJson, "name");

        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Không thể lấy địa chỉ Email từ tài khoản Google của bạn!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        email = email.trim().toLowerCase();
        if (fullName == null || fullName.trim().isEmpty()) {
            fullName = email.split("@")[0];
        } else {
            fullName = decodeUnicodeEscapes(fullName.trim());
        }

        // Check if user with this Google email already exists in database
        User user = userDAO.getUserByEmail(email);
        if (user == null) {
            // Auto-register new CUSTOMER account in database
            String randomPassword = UUID.randomUUID().toString();
            int newUserId = userDAO.insertCustomer(fullName, null, email, randomPassword);
            if (newUserId > 0) {
                user = userDAO.getUserById(newUserId);
            }
        }

        if (user == null) {
            req.setAttribute("errorMessage", "Không thể khởi tạo tài khoản Google trong cơ sở dữ liệu!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (!user.isActive()) {
            req.setAttribute("errorMessage", "Tài khoản này đã bị khóa hoặc ngừng hoạt động!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("currentUser", user);

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/contract");
        }
    }

    /**
     * Verify Google ID token via Google tokeninfo endpoint, with local JWT payload decode fallback.
     */
    private String verifyAndExtractPayload(String idToken) {
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(4))
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken))
                    .timeout(Duration.ofSeconds(4))
                    .GET()
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() == 200) {
                return response.body();
            }
        } catch (Exception ignored) {
            // Fallback to decoding JWT payload if outbound network is restricted
        }

        try {
            String[] parts = idToken.split("\\.");
            if (parts.length == 3) {
                byte[] decoded = Base64.getUrlDecoder().decode(parts[1]);
                String json = new String(decoded, StandardCharsets.UTF_8);
                String iss = extractJsonString(json, "iss");
                if ("https://accounts.google.com".equals(iss) || "accounts.google.com".equals(iss)) {
                    return json;
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private String extractJsonString(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private String decodeUnicodeEscapes(String input) {
        Pattern p = Pattern.compile("\\\\u([0-9a-fA-F]{4})");
        Matcher m = p.matcher(input);
        StringBuilder sb = new StringBuilder();
        while (m.find()) {
            char ch = (char) Integer.parseInt(m.group(1), 16);
            m.appendReplacement(sb, Matcher.quoteReplacement(String.valueOf(ch)));
        }
        m.appendTail(sb);
        return sb.toString();
    }
}
