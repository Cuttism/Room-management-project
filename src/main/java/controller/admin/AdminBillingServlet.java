package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Contract;
import model.Invoice;
import model.ServiceRate;
import service.AdminService;

import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for Batch Utility Billing (Chốt điện nước) and Invoice Management.
 */
@WebServlet(name = "AdminBillingServlet", urlPatterns = {"/admin/billing", "/admin/billing/batch-save", "/admin/invoices", "/admin/invoices/status"})
public class AdminBillingServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/admin/invoices".equals(servletPath)) {
            List<Invoice> invoices = adminService.getAllInvoices();
            req.setAttribute("invoices", invoices);
            req.getRequestDispatcher("/WEB-INF/views/admin/invoice-list.jsp").forward(req, resp);
            return;
        }

        // Default: /admin/billing (Batch entry page)
        LocalDate now = LocalDate.now();
        int month = parseId(req.getParameter("month"));
        int year = parseId(req.getParameter("year"));
        if (month < 1 || month > 12) month = now.getMonthValue();
        if (year < 2000) year = now.getYear();

        List<Contract> activeContracts = adminService.getActiveContracts();
        ServiceRate rates = adminService.getServiceRates();

        // Map contractId -> previous reading & whether current period is already billed
        Map<Integer, Invoice> latestInvoices = new HashMap<>();
        Map<Integer, Boolean> alreadyBilledMap = new HashMap<>();
        for (Contract c : activeContracts) {
            Invoice lastInv = adminService.getLatestInvoice(c.getContractId());
            if (lastInv != null) {
                latestInvoices.put(c.getContractId(), lastInv);
            }
            alreadyBilledMap.put(c.getContractId(), adminService.isInvoiceExist(c.getContractId(), month, year));
        }

        req.setAttribute("contracts", activeContracts);
        req.setAttribute("rates", rates);
        req.setAttribute("latestInvoices", latestInvoices);
        req.setAttribute("alreadyBilledMap", alreadyBilledMap);
        req.setAttribute("billingMonth", month);
        req.setAttribute("billingYear", year);

        req.getRequestDispatcher("/WEB-INF/views/admin/billing-batch.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();

        if ("/admin/invoices/status".equals(servletPath)) {
            int invoiceId = parseId(req.getParameter("invoiceId"));
            String status = req.getParameter("status");
            adminService.updateInvoicePaymentStatus(invoiceId, status);
            resp.sendRedirect(req.getContextPath() + "/admin/invoices?msg=StatusUpdated");
            return;
        }

        if ("/admin/billing/batch-save".equals(servletPath)) {
            int month = parseId(req.getParameter("billingMonth"));
            int year = parseId(req.getParameter("billingYear"));
            String[] contractIds = req.getParameterValues("contractId");

            int createdCount = 0;
            int skippedCount = 0;
            int invalidCount = 0;

            if (contractIds != null) {
                for (String cIdStr : contractIds) {
                    int cId = parseId(cIdStr);
                    String newElecStr = req.getParameter("newElec_" + cId);
                    String newWaterStr = req.getParameter("newWater_" + cId);

                    // Skip rows where admin left readings blank
                    if ((newElecStr == null || newElecStr.trim().isEmpty())
                            && (newWaterStr == null || newWaterStr.trim().isEmpty())) {
                        continue;
                    }

                    int oldElec = parseId(req.getParameter("oldElec_" + cId));
                    int oldWater = parseId(req.getParameter("oldWater_" + cId));
                    Integer newElec = parseNullableInt(newElecStr);
                    Integer newWater = parseNullableInt(newWaterStr);

                    if (newElec == null || newWater == null || newElec < oldElec || newWater < oldWater) {
                        invalidCount++;
                        continue;
                    }

                    if (adminService.isInvoiceExist(cId, month, year)) {
                        skippedCount++;
                        continue;
                    }

                    if (adminService.createMonthlyInvoice(cId, month, year, oldElec, newElec, oldWater, newWater)) {
                        createdCount++;
                    }
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/invoices?msg=BatchInvoicesCreated"
                    + "&created=" + createdCount
                    + "&skipped=" + skippedCount
                    + "&invalid=" + invalidCount);
        }
    }

    private Integer parseNullableInt(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (Exception e) {
            return null;
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
