package controller.guest;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;

/**
 * Controller for Guest registration (Sign Up): GET/POST /guest/register and /register.
 */
@WebServlet(name = "GuestRegisterServlet", urlPatterns = {"/guest/register", "/register"})
public class GuestRegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        req.setAttribute("enteredFullName", fullName);
        req.setAttribute("enteredPhone", phone);
        req.setAttribute("enteredUsername", username);

        if (fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng điền đầy đủ tất cả các trường thông tin!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        if (password.trim().length() < 6) {
            req.setAttribute("errorMessage", "Mật khẩu phải có ít nhất 6 ký tự!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        if (confirmPassword != null && !password.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        // Check if username already exists in database
        User existingUser = userDAO.getUserByUsername(username);
        if (existingUser != null) {
            req.setAttribute("errorMessage", "Tên đăng nhập '" + username + "' đã có người sử dụng. Vui lòng chọn tên khác!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        // Insert new customer into Users table in SQL Server
        int newId = userDAO.insertCustomer(fullName.trim(), phone.trim(), username, password.trim());
        if (newId > 0) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=registered");
        } else {
            req.setAttribute("errorMessage", "Có lỗi kết nối cơ sở dữ liệu trong quá trình đăng ký. Vui lòng thử lại!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
        }
    }
}
