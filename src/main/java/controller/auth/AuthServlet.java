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
 * Controller for User Authentication (Login & Logout).
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/login", "/logout"})
public class AuthServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/logout".equals(servletPath)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/login?msg=logged_out");
            return;
        }

        // Check if message passed
        String msg = req.getParameter("msg");
        if ("registered".equals(msg)) {
            req.setAttribute("successMessage", "Đăng ký tài khoản thành công! Vui lòng đăng nhập.");
        } else if ("logged_out".equals(msg)) {
            req.setAttribute("successMessage", "Đã đăng xuất khỏi hệ thống thành công.");
        } else if ("auth_required".equals(msg)) {
            req.setAttribute("errorMessage", "Vui lòng đăng nhập để truy cập trang này.");
        } else if ("forbidden".equals(msg)) {
            req.setAttribute("errorMessage", "Tài khoản của bạn không có quyền truy cập khu vực này.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            req.setAttribute("enteredUsername", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        User user = userDAO.getUserByUsername(username);

        // Simple password comparison (or add hash check if BCrypt used)
        if (user == null || !password.equals(user.getPassword())) {
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            req.setAttribute("enteredUsername", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (!user.isActive()) {
            req.setAttribute("errorMessage", "Tài khoản này đã bị khóa hoặc ngừng hoạt động!");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // Store user in session
        HttpSession session = req.getSession();
        session.setAttribute("currentUser", user);

        // Redirect based on role
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/contract");
        }
    }
}
