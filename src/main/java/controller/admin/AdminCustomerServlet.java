package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.AdminService;

import java.io.IOException;
import java.util.List;

/**
 * Controller for Admin User & Customer Account Management (CRUD + Lock/Unlock stored in database).
 */
@WebServlet(name = "AdminCustomerServlet", urlPatterns = {
    "/admin/customers",
    "/admin/customers/create",
    "/admin/customers/edit",
    "/admin/customers/toggle"
})
public class AdminCustomerServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        switch (servletPath) {
            case "/admin/customers/create":
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                break;

            case "/admin/customers/edit":
                int userId = parseId(req.getParameter("id"));
                User user = adminService.getUserById(userId);
                if (user == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/customers?error=UserNotFound");
                    return;
                }
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", user);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                break;

            case "/admin/customers":
            default:
                List<User> users = adminService.getAllUsers();
                req.setAttribute("users", users);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();

        if ("/admin/customers/toggle".equals(servletPath)) {
            int userId = parseId(req.getParameter("userId"));
            boolean active = "true".equalsIgnoreCase(req.getParameter("active")) || "1".equals(req.getParameter("active"));
            User currentUser = (req.getSession(false) != null) ? (User) req.getSession(false).getAttribute("currentUser") : null;
            if (currentUser != null && currentUser.getUserId() == userId && !active) {
                resp.sendRedirect(req.getContextPath() + "/admin/customers?error=CannotLockSelf");
                return;
            }
            adminService.toggleUserActive(userId, active);
            resp.sendRedirect(req.getContextPath() + "/admin/customers?msg=StatusUpdated");
            return;
        }

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String role = req.getParameter("role");
        boolean isActive = req.getParameter("isActive") != null;

        if ("/admin/customers/create".equals(servletPath)) {
            if (fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || password == null || password.trim().isEmpty()) {
                req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ họ tên, email, số điện thoại và mật khẩu!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (!email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Định dạng địa chỉ Email không hợp lệ!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (!phone.trim().matches("^0\\d{9}$")) {
                req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (password.trim().length() < 6) {
                req.setAttribute("errorMessage", "Ràng buộc bảo mật: Mật khẩu khởi tạo phải có ít nhất 6 ký tự!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (adminService.getUserByEmail(email.trim()) != null) {
                req.setAttribute("errorMessage", "Ràng buộc chống trùng: Địa chỉ email '" + email.trim() + "' đã tồn tại!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (adminService.getUserByPhone(phone.trim()) != null) {
                req.setAttribute("errorMessage", "Ràng buộc chống trùng: Số điện thoại '" + phone.trim() + "' đã tồn tại!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            int newId = adminService.createUser(
                email.trim(),
                password.trim(),
                fullName.trim(),
                phone.trim(),
                role != null ? role : "CUSTOMER",
                isActive
            );

            if (newId > 0) {
                resp.sendRedirect(req.getContextPath() + "/admin/customers?msg=CreatedSuccessfully");
            } else {
                req.setAttribute("errorMessage", "Không thể tạo tài khoản mới trong cơ sở dữ liệu!");
                req.setAttribute("isEdit", false);
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
            }

        } else if ("/admin/customers/edit".equals(servletPath)) {
            int userId = parseId(req.getParameter("userId"));
            String cleanEmail = email != null ? email.trim() : "";
            String cleanPhone = phone != null ? phone.trim() : "";

            if (!cleanEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Định dạng địa chỉ Email không hợp lệ!");
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", adminService.getUserById(userId));
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (!cleanPhone.isEmpty() && !cleanPhone.matches("^0\\d{9}$")) {
                req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0!");
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", adminService.getUserById(userId));
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (password != null && !password.trim().isEmpty() && password.trim().length() < 6) {
                req.setAttribute("errorMessage", "Ràng buộc bảo mật: Mật khẩu mới phải có ít nhất 6 ký tự!");
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", adminService.getUserById(userId));
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            User existingEmailUser = adminService.getUserByEmail(cleanEmail);
            if (existingEmailUser != null && existingEmailUser.getUserId() != userId) {
                req.setAttribute("errorMessage", "Ràng buộc chống trùng: Địa chỉ email '" + cleanEmail + "' đã thuộc về một tài khoản khác!");
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", adminService.getUserById(userId));
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                return;
            }

            if (!cleanPhone.isEmpty()) {
                User existingPhoneUser = adminService.getUserByPhone(cleanPhone);
                if (existingPhoneUser != null && existingPhoneUser.getUserId() != userId) {
                    req.setAttribute("errorMessage", "Ràng buộc chống trùng: Số điện thoại '" + cleanPhone + "' đã thuộc về một tài khoản khác!");
                    req.setAttribute("isEdit", true);
                    req.setAttribute("customer", adminService.getUserById(userId));
                    req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
                    return;
                }
            }
            boolean ok = adminService.updateUser(
                userId,
                email != null ? email.trim() : "",
                fullName != null ? fullName.trim() : "",
                phone != null ? phone.trim() : "",
                role != null ? role : "CUSTOMER",
                isActive,
                password
            );
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/customers?msg=UpdatedSuccessfully");
            } else {
                req.setAttribute("errorMessage", "Không thể cập nhật thông tin tài khoản (Email hoặc SĐT có thể đã trùng)!");
                req.setAttribute("isEdit", true);
                req.setAttribute("customer", adminService.getUserById(userId));
                req.getRequestDispatcher("/WEB-INF/views/admin/customer-form.jsp").forward(req, resp);
            }
        }
    }

    private int parseId(String val) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return 0;
        }
    }
}
