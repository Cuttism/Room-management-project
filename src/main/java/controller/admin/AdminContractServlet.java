package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Contract;
import model.Room;
import model.User;
import service.AdminService;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 * Controller for Contract Management: Creation, Liquidation/Settlement with deposit offset.
 */
@WebServlet(name = "AdminContractServlet", urlPatterns = {"/admin/contracts", "/admin/contracts/create", "/admin/contracts/terminate"})
public class AdminContractServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        switch (servletPath) {
            case "/admin/contracts/create":
                List<Room> availableRooms = adminService.getAvailableRooms();
                List<User> customers = adminService.getActiveCustomers();
                req.setAttribute("rooms", availableRooms);
                req.setAttribute("customers", customers);
                req.getRequestDispatcher("/WEB-INF/views/admin/contract-form.jsp").forward(req, resp);
                break;

            case "/admin/contracts/terminate":
                int contractId = parseId(req.getParameter("id"));
                Contract contract = adminService.getContractById(contractId);
                if (contract == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/contracts?error=NotFound");
                    return;
                }
                req.setAttribute("contract", contract);
                req.setAttribute("rates", adminService.getServiceRates());
                req.setAttribute("latestInvoice", adminService.getLatestInvoice(contractId));
                req.getRequestDispatcher("/WEB-INF/views/admin/contract-terminate.jsp").forward(req, resp);
                break;

            case "/admin/contracts":
            default:
                List<Contract> contracts = adminService.getAllContracts();
                req.setAttribute("contracts", contracts);
                req.getRequestDispatcher("/WEB-INF/views/admin/contract-list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();

        if ("/admin/contracts/create".equals(servletPath)) {
            int roomId = parseId(req.getParameter("roomId"));
            int userId = parseId(req.getParameter("userId"));
            String startDateStr = req.getParameter("startDate");
            String endDateStr = req.getParameter("endDate");
            String depositStr = req.getParameter("depositAmount");

            try {
                Date startDate = Date.valueOf(startDateStr);
                Date endDate = Date.valueOf(endDateStr);
                BigDecimal deposit = new BigDecimal(depositStr);

                adminService.createContract(roomId, userId, startDate, endDate, deposit);
                resp.sendRedirect(req.getContextPath() + "/admin/contracts?msg=ContractCreated");
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Thông tin hợp đồng không hợp lệ: " + e.getMessage());
                req.setAttribute("rooms", adminService.getAvailableRooms());
                req.setAttribute("customers", adminService.getActiveCustomers());
                req.getRequestDispatcher("/WEB-INF/views/admin/contract-form.jsp").forward(req, resp);
            }

        } else if ("/admin/contracts/terminate".equals(servletPath)) {
            int contractId = parseId(req.getParameter("contractId"));
            int roomId = parseId(req.getParameter("roomId"));
            String actualEndDateStr = req.getParameter("actualEndDate");
            int finalElec = parseId(req.getParameter("finalElec"));
            int finalWater = parseId(req.getParameter("finalWater"));

            try {
                Date actualEndDate = Date.valueOf(actualEndDateStr);
                Contract c = adminService.getContractById(contractId);
                // Perform settlement calculation
                Map<String, Object> settlement = adminService.calculateSettlement(c, actualEndDate, finalElec, finalWater);
                // Terminate contract and free room
                adminService.terminateContract(contractId, roomId, actualEndDate);

                // Pass settlement results to summary view or redirect
                req.getSession().setAttribute("lastSettlement", settlement);
                req.getSession().setAttribute("settledContract", c);
                resp.sendRedirect(req.getContextPath() + "/admin/contracts?msg=TerminatedSuccessfully");
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/contracts/terminate?id=" + contractId + "&error=Failed");
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
