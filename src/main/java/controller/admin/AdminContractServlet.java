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

                if (!endDate.after(startDate)) {
                    throw new IllegalArgumentException("Ngày kết thúc hợp đồng phải lớn hơn ngày bắt đầu thuê!");
                }
                if (deposit.compareTo(BigDecimal.ZERO) < 0) {
                    throw new IllegalArgumentException("Số tiền đặt cọc không được nhỏ hơn 0 VNĐ!");
                }
                Room room = adminService.getRoomById(roomId);
                if (room == null || !"AVAILABLE".equalsIgnoreCase(room.getStatus()) || adminService.hasActiveContractByRoomId(roomId)) {
                    throw new IllegalArgumentException("Phòng đã chọn hiện không còn trống hoặc đang có một hợp đồng hiệu lực khác!");
                }
                User customer = adminService.getUserById(userId);
                if (customer == null || !customer.isActive()) {
                    throw new IllegalArgumentException("Tài khoản khách thuê không tồn tại hoặc đang bị khóa!");
                }

                int contractId = adminService.createContract(roomId, userId, startDate, endDate, deposit);
                if (contractId <= 0) {
                    throw new IllegalStateException("Không thể lưu hợp đồng do vi phạm ràng buộc cơ sở dữ liệu!");
                }
                resp.sendRedirect(req.getContextPath() + "/admin/contracts?msg=ContractCreated");
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Bị chặn bởi ràng buộc hợp đồng: " + e.getMessage());
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

            Contract c = adminService.getContractById(contractId);
            if (c == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/contracts?error=NotFound");
                return;
            }

            try {
                Date actualEndDate = Date.valueOf(actualEndDateStr);
                if (c.getStartDate() != null && actualEndDate.before(c.getStartDate())) {
                    throw new IllegalArgumentException("Ngày trả phòng thực tế không được nhỏ hơn ngày bắt đầu hợp đồng (" + c.getStartDate() + ")!");
                }

                model.Invoice latestInv = adminService.getLatestInvoice(contractId);
                int oldElec = latestInv != null ? latestInv.getNewElec() : 0;
                int oldWater = latestInv != null ? latestInv.getNewWater() : 0;

                if (finalElec < oldElec) {
                    throw new IllegalArgumentException("Chỉ số điện chốt cuối (" + finalElec + " kWh) không được nhỏ hơn chỉ số điện cũ (" + oldElec + " kWh)!");
                }
                if (finalWater < oldWater) {
                    throw new IllegalArgumentException("Chỉ số nước chốt cuối (" + finalWater + " m3) không được nhỏ hơn chỉ số nước cũ (" + oldWater + " m3)!");
                }

                // Perform settlement calculation
                Map<String, Object> settlement = adminService.calculateSettlement(c, actualEndDate, finalElec, finalWater);
                // Terminate contract and free room
                adminService.terminateContract(contractId, roomId, actualEndDate);

                // Pass settlement results to summary view or redirect
                req.getSession().setAttribute("lastSettlement", settlement);
                req.getSession().setAttribute("settledContract", c);
                resp.sendRedirect(req.getContextPath() + "/admin/contracts?msg=TerminatedSuccessfully");
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Bị chặn bởi ràng buộc quyết toán: " + e.getMessage());
                req.setAttribute("contract", c);
                req.setAttribute("rates", adminService.getServiceRates());
                req.setAttribute("latestInvoice", adminService.getLatestInvoice(contractId));
                req.getRequestDispatcher("/WEB-INF/views/admin/contract-terminate.jsp").forward(req, resp);
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
