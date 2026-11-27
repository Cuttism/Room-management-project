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
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        req.setAttribute("enteredFullName", fullName);
        req.setAttribute("enteredPhone", phone);
        req.setAttribute("enteredEmail", email);

        if (fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || email == null || email.trim().isEmpty()
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

        email = email.trim();
        phone = phone.trim();

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            req.setAttribute("errorMessage", "Định dạng địa chỉ Email không hợp lệ!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        if (!phone.matches("^0\\d{9}$")) {
            req.setAttribute("errorMessage", "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0 (ví dụ: 0912345678)!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        // Check if email already exists in database
        User existingByEmail = userDAO.getUserByEmail(email);
        if (existingByEmail != null) {
            req.setAttribute("errorMessage", "Địa chỉ email '" + email + "' đã được đăng ký. Vui lòng dùng email khác!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        // Check if phone already exists in database
        User existingByPhone = userDAO.getUserByPhone(phone);
        if (existingByPhone != null) {
            req.setAttribute("errorMessage", "Số điện thoại '" + phone + "' đã được đăng ký. Vui lòng dùng số khác!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
            return;
        }

        // Insert new customer into Users table in SQL Server
        int newId = userDAO.insertCustomer(fullName.trim(), phone, email, password.trim());
        if (newId > 0) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=registered");
        } else {
            req.setAttribute("errorMessage", "Có lỗi kết nối cơ sở dữ liệu trong quá trình đăng ký. Vui lòng thử lại!");
            req.getRequestDispatcher("/WEB-INF/views/guest/register.jsp").forward(req, resp);
        }
    }
}
