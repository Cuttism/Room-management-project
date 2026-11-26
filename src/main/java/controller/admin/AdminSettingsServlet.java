package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ServiceRate;
import service.AdminService;

import java.io.IOException;
import java.math.BigDecimal;

/**
 * Controller for Admin Service Rates Configuration (Cài đặt đơn giá điện, nước, internet, rác).
 */
@WebServlet(name = "AdminSettingsServlet", urlPatterns = {"/admin/settings"})
public class AdminSettingsServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ServiceRate rates = adminService.getServiceRates();
        req.setAttribute("rates", rates);
        req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            BigDecimal elec = new BigDecimal(req.getParameter("electricityPerKwh").trim());
            BigDecimal water = new BigDecimal(req.getParameter("waterPerM3").trim());
            BigDecimal internet = new BigDecimal(req.getParameter("internetFee").trim());
            BigDecimal trash = new BigDecimal(req.getParameter("trashFee").trim());

            ServiceRate updated = new ServiceRate(1, elec, water, internet, trash);
            if (adminService.updateServiceRates(updated)) {
                resp.sendRedirect(req.getContextPath() + "/admin/settings?msg=Updated");
            } else {
                req.setAttribute("errorMessage", "Không thể lưu đơn giá dịch vụ vào cơ sở dữ liệu!");
                req.setAttribute("rates", updated);
                req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Đơn giá nhập vào không hợp lệ: " + e.getMessage());
            req.setAttribute("rates", adminService.getServiceRates());
            req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
        }
    }
}
