package controller.customer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import dal.ContractDAO;
import dal.InvoiceDAO;
import dal.MaintenanceTicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Contract;
import model.Invoice;
import model.MaintenanceTicket;
import model.User;

/**
 * Controller for Customer module: Dashboard (Active Contract), Invoices, and Tickets.
 */
@WebServlet(name = "CustomerPortalServlet", urlPatterns = {
    "/customer/contract",
    "/customer/invoices",
    "/customer/invoices/*",
    "/customer/tickets",
    "/customer/tickets/*"
})
public class CustomerPortalServlet extends HttpServlet {
    private final ContractDAO contractDAO = new ContractDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final MaintenanceTicketDAO ticketDAO = new MaintenanceTicketDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=auth_required");
            return;
        }

        switch (servletPath) {
            case "/customer/contract":
                Contract myContract = findActiveContractByUserId(currentUser.getUserId());
                req.setAttribute("contract", myContract);
                req.getRequestDispatcher("/WEB-INF/views/customer/dashboard.jsp").forward(req, resp);
                break;

            case "/customer/invoices":
                List<Invoice> allInvoices = invoiceDAO.getAllInvoices();
                List<Invoice> myInvoices = new ArrayList<>();
                for (Invoice inv : allInvoices) {
                    if (inv.getContract() != null && inv.getContract().getUserId() == currentUser.getUserId()) {
                        myInvoices.add(inv);
                    }
                }
                req.setAttribute("invoices", myInvoices);
                req.getRequestDispatcher("/WEB-INF/views/customer/invoices.jsp").forward(req, resp);
                break;

            case "/customer/tickets":
                List<MaintenanceTicket> allTickets = ticketDAO.getAllTickets();
                List<MaintenanceTicket> myTickets = new ArrayList<>();
                for (MaintenanceTicket t : allTickets) {
                    if (t.getUserId() == currentUser.getUserId()) {
                        myTickets.add(t);
                    }
                }
                req.setAttribute("tickets", myTickets);
                req.setAttribute("activeContract", findActiveContractByUserId(currentUser.getUserId()));
                req.getRequestDispatcher("/WEB-INF/views/customer/tickets.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/guest/rooms");
                break;
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

        String servletPath = req.getServletPath();
        String pathInfo = req.getPathInfo();

        // 1. Create a new maintenance ticket: POST /customer/tickets
        if ("/customer/tickets".equals(servletPath) && (pathInfo == null || "/".equals(pathInfo))) {
            Contract activeContract = findActiveContractByUserId(currentUser.getUserId());
            if (activeContract == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?error=NoActiveContract");
                return;
            }

            String title = req.getParameter("title");
            String priority = req.getParameter("priority");
            String description = req.getParameter("description");

            if (title == null || title.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?error=InvalidInput");
                return;
            }

            int ticketId = ticketDAO.insertTicket(
                activeContract.getRoomId(),
                currentUser.getUserId(),
                title.trim(),
                description != null ? description.trim() : "",
                priority
            );

            if (ticketId > 0) {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?msg=TicketCreated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?error=CreateFailed");
            }
            return;
        }

        // 2. Cancel a maintenance ticket: POST /customer/tickets/{id}/cancel
        if ("/customer/tickets".equals(servletPath) && pathInfo != null && pathInfo.endsWith("/cancel")) {
            int ticketId = extractIdFromPathInfo(pathInfo, "/cancel");
            if (ticketId > 0 && ticketDAO.cancelCustomerTicket(ticketId, currentUser.getUserId())) {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?msg=TicketCancelled");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customer/tickets?error=CancelFailed");
            }
            return;
        }

        // 3. Pay an invoice via VietQR: POST /customer/invoices/{id}/pay
        if ("/customer/invoices".equals(servletPath) && pathInfo != null && pathInfo.endsWith("/pay")) {
            int invoiceId = extractIdFromPathInfo(pathInfo, "/pay");
            if (invoiceId > 0 && invoiceDAO.payInvoiceByCustomer(invoiceId, currentUser.getUserId(), "VIETQR")) {
                resp.sendRedirect(req.getContextPath() + "/customer/invoices?msg=PaymentInitiated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customer/invoices?error=PaymentFailed");
            }
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/customer/contract");
    }

    private Contract findActiveContractByUserId(int userId) {
        List<Contract> activeContracts = contractDAO.getActiveContracts();
        for (Contract c : activeContracts) {
            if (c.getUserId() == userId) {
                return c;
            }
        }
        return null;
    }

    private int extractIdFromPathInfo(String pathInfo, String suffix) {
        try {
            String raw = pathInfo.substring(0, pathInfo.length() - suffix.length());
            if (raw.startsWith("/")) {
                raw = raw.substring(1);
            }
            return Integer.parseInt(raw);
        } catch (Exception e) {
            return -1;
        }
    }
}
