package service;

import dal.ContractDAO;
import dal.InvoiceDAO;
import dal.RoomDAO;
import dal.UserDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Contract;
import model.Invoice;
import model.Room;
import model.ServiceRate;
import model.User;

/**
 * Service implementation handling business logic for Admin operations.
 */
public class AdminService {
    private final RoomDAO roomDAO = new RoomDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final UserDAO userDAO = new UserDAO();
    private final dal.MaintenanceTicketDAO ticketDAO = new dal.MaintenanceTicketDAO();
    private final dal.TransactionDAO transactionDAO = new dal.TransactionDAO();

    // ==========================================
    // 6. User / Customer Management & Settings
    // ==========================================
    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    public User getUserByUsername(String username) {
        return userDAO.getUserByUsername(username);
    }

    public int createUser(String username, String password, String fullName, String phone, String role, boolean isActive) {
        return userDAO.insertUser(username, password, fullName, phone, role, isActive);
    }

    public boolean updateUser(int userId, String fullName, String phone, String role, boolean isActive, String newPassword) {
        return userDAO.updateUser(userId, fullName, phone, role, isActive, newPassword);
    }

    public boolean toggleUserActive(int userId, boolean isActive) {
        return userDAO.toggleUserActive(userId, isActive);
    }

    public boolean updateServiceRates(ServiceRate rates) {
        return invoiceDAO.updateServiceRates(rates);
    }

    public List<model.Transaction> getAllTransactions() {
        return transactionDAO.getAllTransactions();
    }

    // ==========================================
    // 5. Maintenance Tickets
    // ==========================================
    public List<model.MaintenanceTicket> getAllTickets() {
        return ticketDAO.getAllTickets();
    }

    public boolean updateTicketStatus(int ticketId, String status) {
        return ticketDAO.updateTicketStatus(ticketId, status);
    }

    // ==========================================
    // 1. Room Management (CRUD)
    // ==========================================

    public List<Room> getAllRooms() {
        return roomDAO.getAllRooms();
    }

    public List<Room> getAvailableRooms() {
        return roomDAO.getRoomsByStatus("AVAILABLE");
    }

    public Room getRoomById(int roomId) {
        return roomDAO.getRoomById(roomId);
    }

    public boolean isRoomNumberExists(String roomNumber, int excludeRoomId) {
        return roomDAO.isRoomNumberExists(roomNumber, excludeRoomId);
    }

    public int createRoom(Room room, List<String> imageUrls) {
        return createRoom(room, imageUrls, "Khu A - Tầng 1");
    }

    public int createRoom(Room room, List<String> imageUrls, String region) {
        int roomId = roomDAO.insertRoom(room);
        if (roomId > 0 && imageUrls != null && !imageUrls.isEmpty()) {
            roomDAO.insertRoomImages(roomId, imageUrls, region);
        }
        return roomId;
    }

    public boolean updateRoom(Room room, List<String> newImageUrls) {
        return updateRoom(room, newImageUrls, "Khu A - Tầng 1");
    }

    public boolean updateRoom(Room room, List<String> newImageUrls, String region) {
        boolean ok = roomDAO.updateRoom(room);
        if (ok && newImageUrls != null && !newImageUrls.isEmpty()) {
            roomDAO.insertRoomImages(room.getRoomId(), newImageUrls, region);
        }
        return ok;
    }

    public List<model.RoomImage> getLibraryImages() {
        return roomDAO.getLibraryImages();
    }

    public boolean deleteRoomImage(int imageId) {
        return roomDAO.deleteRoomImage(imageId);
    }

    public boolean softDeleteRoom(int roomId) {
        return roomDAO.softDeleteRoom(roomId);
    }

    // ==========================================
    // 2. Contract Management & Settlement
    // ==========================================

    public List<Contract> getAllContracts() {
        return contractDAO.getAllContracts();
    }

    public List<Contract> getActiveContracts() {
        return contractDAO.getActiveContracts();
    }

    public Contract getContractById(int contractId) {
        return contractDAO.getContractById(contractId);
    }

    public List<User> getActiveCustomers() {
        return userDAO.getActiveCustomers();
    }

    public int createContract(int roomId, int userId, Date startDate, Date endDate, BigDecimal depositAmount) {
        Contract contract = new Contract();
        contract.setRoomId(roomId);
        contract.setUserId(userId);
        contract.setStartDate(startDate);
        contract.setEndDate(endDate);
        contract.setDepositAmount(depositAmount);
        return contractDAO.createContract(contract);
    }

    /**
     * Settle & Terminate contract before/on due date:
     * Calculates pro-rated daily room fee from actualEndDate, settles with deposit amount,
     * and persists the final settlement invoice & transaction.
     */
    public Map<String, Object> calculateSettlement(Contract contract, Date actualEndDate, int finalElec, int finalWater) {
        Map<String, Object> result = new HashMap<>();

        // Base room price
        Room room = roomDAO.getRoomById(contract.getRoomId());
        BigDecimal basePrice = room != null ? room.getBasePrice() : BigDecimal.ZERO;

        // Calculate actual days occupied in the final billing month based on actualEndDate and contract.startDate
        LocalDate endLocal = (actualEndDate != null) ? actualEndDate.toLocalDate() : LocalDate.now();
        LocalDate billingPeriodStart = endLocal.withDayOfMonth(1);
        if (contract.getStartDate() != null) {
            LocalDate contractStart = contract.getStartDate().toLocalDate();
            if (contractStart.isAfter(billingPeriodStart)) {
                billingPeriodStart = contractStart;
            }
        }

        long days;
        if (endLocal.isBefore(billingPeriodStart)) {
            days = 0;
        } else {
            days = Math.min(30, ChronoUnit.DAYS.between(billingPeriodStart, endLocal) + 1);
        }

        // Daily rate: basePrice / 30
        BigDecimal dailyRate = basePrice.divide(new BigDecimal("30"), 2, RoundingMode.HALF_UP);
        BigDecimal proRatedRoomFee = dailyRate.multiply(BigDecimal.valueOf(days));

        // Calculate electric & water fee
        ServiceRate rates = invoiceDAO.getServiceRates();
        Invoice latestInv = invoiceDAO.getLatestInvoiceByContractId(contract.getContractId());
        int oldElec = latestInv != null ? latestInv.getNewElec() : 0;
        int oldWater = latestInv != null ? latestInv.getNewWater() : 0;

        int usedElec = Math.max(0, finalElec - oldElec);
        int usedWater = Math.max(0, finalWater - oldWater);

        BigDecimal elecFee = rates.getElectricityPerKwh().multiply(BigDecimal.valueOf(usedElec));
        BigDecimal waterFee = rates.getWaterPerM3().multiply(BigDecimal.valueOf(usedWater));
        BigDecimal serviceFee = (days > 0) ? rates.getInternetFee().add(rates.getTrashFee()) : BigDecimal.ZERO;

        BigDecimal totalUsage = proRatedRoomFee.add(elecFee).add(waterFee).add(serviceFee);
        BigDecimal deposit = contract.getDepositAmount() != null ? contract.getDepositAmount() : BigDecimal.ZERO;

        // Refund = Deposit - TotalUsage (If positive: refund to tenant; if negative: tenant must pay extra)
        BigDecimal refundAmount = deposit.subtract(totalUsage);

        // Persist final settlement invoice & transaction record
        int settlementInvoiceId = invoiceDAO.recordSettlementInvoice(
            contract.getContractId(),
            endLocal.getMonthValue(),
            endLocal.getYear(),
            oldElec,
            Math.max(oldElec, finalElec),
            oldWater,
            Math.max(oldWater, finalWater),
            totalUsage
        );

        result.put("occupiedDays", days);
        result.put("proRatedRoomFee", proRatedRoomFee);
        result.put("usedElec", usedElec);
        result.put("elecFee", elecFee);
        result.put("usedWater", usedWater);
        result.put("waterFee", waterFee);
        result.put("serviceFee", serviceFee);
        result.put("totalUsage", totalUsage);
        result.put("deposit", deposit);
        result.put("refundAmount", refundAmount);
        result.put("settlementInvoiceId", settlementInvoiceId);

        return result;
    }

    public boolean terminateContract(int contractId, int roomId, Date actualEndDate) {
        return contractDAO.terminateContract(contractId, roomId, actualEndDate);
    }

    // ==========================================
    // 3. Batch Utility Billing (Chốt điện nước)
    // ==========================================

    public ServiceRate getServiceRates() {
        return invoiceDAO.getServiceRates();
    }

    public Invoice getLatestInvoice(int contractId) {
        return invoiceDAO.getLatestInvoiceByContractId(contractId);
    }

    public List<Invoice> getAllInvoices() {
        return invoiceDAO.getAllInvoices();
    }

    public boolean isInvoiceExist(int contractId, int month, int year) {
        return invoiceDAO.isInvoiceExist(contractId, month, year);
    }

    public boolean createMonthlyInvoice(int contractId, int month, int year,
                                        int oldElec, int newElec, int oldWater, int newWater) {
        if (invoiceDAO.isInvoiceExist(contractId, month, year)) {
            return false; // Invoice already exists for this period
        }

        Contract contract = contractDAO.getContractById(contractId);
        if (contract == null) return false;

        Room room = roomDAO.getRoomById(contract.getRoomId());
        BigDecimal roomPrice = room != null ? room.getBasePrice() : BigDecimal.ZERO;

        ServiceRate rates = invoiceDAO.getServiceRates();
        int usedElec = Math.max(0, newElec - oldElec);
        int usedWater = Math.max(0, newWater - oldWater);

        BigDecimal elecFee = rates.getElectricityPerKwh().multiply(new BigDecimal(usedElec));
        BigDecimal waterFee = rates.getWaterPerM3().multiply(new BigDecimal(usedWater));
        BigDecimal serviceFee = rates.getInternetFee().add(rates.getTrashFee());

        BigDecimal totalAmount = roomPrice.add(elecFee).add(waterFee).add(serviceFee);

        Invoice inv = new Invoice();
        inv.setContractId(contractId);
        inv.setBillingMonth(month);
        inv.setBillingYear(year);
        inv.setOldElec(oldElec);
        inv.setNewElec(newElec);
        inv.setOldWater(oldWater);
        inv.setNewWater(newWater);
        inv.setTotalAmount(totalAmount);
        inv.setPaymentStatus("UNPAID");

        return invoiceDAO.insertInvoice(inv) > 0;
    }

    public boolean updateInvoicePaymentStatus(int invoiceId, String status) {
        return invoiceDAO.updatePaymentStatus(invoiceId, status);
    }

    // ==========================================
    // 4. Dashboard KPIs & Revenue
    // ==========================================

    public Map<String, Object> getDashboardKPIs(int month, int year) {
        return invoiceDAO.getDashboardKPIs(month, year);
    }

    public Map<String, BigDecimal> getRevenueLast6Months() {
        return invoiceDAO.getRevenueLast6Months();
    }
}
