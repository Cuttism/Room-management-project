package controller.admin;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Invoice;
import service.AdminService;

/**
 * Controller for Admin Dashboard (KPIs, 6-month Revenue Chart, Recent Invoices).
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard", "/admin"})
public class AdminDashboardServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate now = LocalDate.now();
        int month = now.getMonthValue();
        int year = now.getYear();

        // 1. Get KPI numbers
        Map<String, Object> kpis = adminService.getDashboardKPIs(month, year);
        req.setAttribute("kpis", kpis);
        req.setAttribute("currentMonth", month);
        req.setAttribute("currentYear", year);

        // 2. Get Revenue for last 6 months for chart
        Map<String, BigDecimal> revenueStats = adminService.getRevenueLast6Months();
        req.setAttribute("revenueStats", revenueStats);

        // 3. Get recent invoices
        List<Invoice> recentInvoices = adminService.getAllInvoices();
        if (recentInvoices.size() > 5) {
            recentInvoices = recentInvoices.subList(0, 5);
        }
        req.setAttribute("recentInvoices", recentInvoices);

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
