package controller.admin;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MaintenanceTicket;
import service.AdminService;

/**
 * Controller for Admin Maintenance Tickets Management.
 */
@WebServlet(name = "AdminTicketServlet", urlPatterns = {"/admin/tickets", "/admin/tickets/status"})
public class AdminTicketServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<MaintenanceTicket> tickets = adminService.getAllTickets();
        req.setAttribute("tickets", tickets);
        req.getRequestDispatcher("/WEB-INF/views/admin/ticket-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int ticketId = parseId(req.getParameter("ticketId"));
        String status = req.getParameter("status");

        adminService.updateTicketStatus(ticketId, status);
        resp.sendRedirect(req.getContextPath() + "/admin/tickets?msg=Updated");
    }

    private int parseId(String val) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return 0;
        }
    }
}
