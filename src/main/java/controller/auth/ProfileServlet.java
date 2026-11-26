package controller.auth;

import java.io.IOException;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

/**
 * Controller for viewing and updating the logged-in user's profile and password.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/admin/profile", "/customer/profile"})
public class ProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=auth_required");
            return;
        }

        // Refresh user from database
        User freshUser = userDAO.getUserById(currentUser.getUserId());
        if (freshUser != null) {
            session.setAttribute("currentUser", freshUser);
            currentUser = freshUser;
        }

        req.setAttribute("user", currentUser);
        if ("ADMIN".equalsIgnoreCase(currentUser.getRole()) && req.getServletPath().startsWith("/admin")) {
            req.getRequestDispatcher("/WEB-INF/views/admin/profile.jsp").forward(req, resp);
        } else if ("ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            req.getRequestDispatcher("/WEB-INF/views/admin/profile.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=auth_required");
            return;
        }

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String targetView = "ADMIN".equalsIgnoreCase(currentUser.getRole())
                ? "/WEB-INF/views/admin/profile.jsp"
                : "/WEB-INF/views/customer/profile.jsp";

        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Họ tên và số điện thoại không được để trống!");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher(targetView).forward(req, resp);
            return;
        }

        String passwordToSave = null;
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            User dbUser = userDAO.getUserById(currentUser.getUserId());
            if (currentPassword == null || dbUser == null || !currentPassword.equals(dbUser.getPassword())) {
                req.setAttribute("errorMessage", "Mật khẩu hiện tại không chính xác!");
                req.setAttribute("user", currentUser);
                req.getRequestDispatcher(targetView).forward(req, resp);
                return;
            }
            if (newPassword.trim().length() < 6) {
                req.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 6 ký tự!");
                req.setAttribute("user", currentUser);
                req.getRequestDispatcher(targetView).forward(req, resp);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                req.setAttribute("errorMessage", "Mật khẩu mới và xác nhận mật khẩu không khớp!");
                req.setAttribute("user", currentUser);
                req.getRequestDispatcher(targetView).forward(req, resp);
                return;
            }
            passwordToSave = newPassword.trim();
        }

        boolean ok = userDAO.updateProfile(currentUser.getUserId(), fullName.trim(), phone.trim(), passwordToSave);
        if (ok) {
            User updated = userDAO.getUserById(currentUser.getUserId());
            session.setAttribute("currentUser", updated);
            String redirectUrl = "ADMIN".equalsIgnoreCase(currentUser.getRole())
                    ? req.getContextPath() + "/admin/profile?msg=ProfileUpdated"
                    : req.getContextPath() + "/customer/profile?msg=ProfileUpdated";
            resp.sendRedirect(redirectUrl);
        } else {
            req.setAttribute("errorMessage", "Không thể lưu thông tin vào cơ sở dữ liệu!");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher(targetView).forward(req, resp);
        }
    }
}
