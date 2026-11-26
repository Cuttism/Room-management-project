package dal;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import model.Contract;
import model.Invoice;
import model.Room;
import model.ServiceRate;
import model.User;

/**
 * Data Access Object for Invoices and Billing.
 */
public class InvoiceDAO {
    private static final Logger LOGGER = Logger.getLogger(InvoiceDAO.class.getName());

    /**
     * Get default service rates (electricity, water, internet, trash).
     */
    public ServiceRate getServiceRates() {
        String sql = "SELECT TOP 1 rate_id, electricity_per_kwh, water_per_m3, internet_fee, trash_fee FROM ServiceRates";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return new ServiceRate(
                    rs.getInt("rate_id"),
                    rs.getBigDecimal("electricity_per_kwh"),
                    rs.getBigDecimal("water_per_m3"),
                    rs.getBigDecimal("internet_fee"),
                    rs.getBigDecimal("trash_fee")
                );
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getServiceRates", e);
        }
        // Fallback default rates if DB table is empty
        return new ServiceRate(1, new BigDecimal("3500.00"), new BigDecimal("25000.00"), new BigDecimal("100000.00"), new BigDecimal("50000.00"));
    }

    /**
     * Update or insert default service rates in the ServiceRates table.
     */
    public boolean updateServiceRates(ServiceRate rates) {
        String sqlCheck = "SELECT TOP 1 rate_id FROM ServiceRates";
        String sqlUpdate = "UPDATE ServiceRates SET electricity_per_kwh = ?, water_per_m3 = ?, internet_fee = ?, trash_fee = ? WHERE rate_id = ?";
        String sqlInsert = "INSERT INTO ServiceRates (electricity_per_kwh, water_per_m3, internet_fee, trash_fee) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            int rateId = -1;
            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
                 ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    rateId = rs.getInt("rate_id");
                }
            }
            if (rateId > 0) {
                try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                    psUpdate.setBigDecimal(1, rates.getElectricityPerKwh());
                    psUpdate.setBigDecimal(2, rates.getWaterPerM3());
                    psUpdate.setBigDecimal(3, rates.getInternetFee());
                    psUpdate.setBigDecimal(4, rates.getTrashFee());
                    psUpdate.setInt(5, rateId);
                    return psUpdate.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert)) {
                    psInsert.setBigDecimal(1, rates.getElectricityPerKwh());
                    psInsert.setBigDecimal(2, rates.getWaterPerM3());
                    psInsert.setBigDecimal(3, rates.getInternetFee());
                    psInsert.setBigDecimal(4, rates.getTrashFee());
                    return psInsert.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateServiceRates", e);
        }
        return false;
    }

    /**
     * Get all invoices with contract and room/user info.
     */
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT i.invoice_id, i.contract_id, i.billing_month, i.billing_year, i.old_elec, i.new_elec, " +
                     "i.old_water, i.new_water, i.total_amount, i.payment_status, " +
                     "c.room_id, c.user_id, r.room_number, u.full_name " +
                     "FROM Invoices i " +
                     "JOIN Contracts c ON i.contract_id = c.contract_id " +
                     "JOIN Rooms r ON c.room_id = r.room_id " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "ORDER BY i.billing_year DESC, i.billing_month DESC, i.invoice_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToInvoice(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllInvoices", e);
        }
        return list;
    }

    /**
     * Get the latest invoice for a contract to find the previous electricity and water meter readings.
     */
    public Invoice getLatestInvoiceByContractId(int contractId) {
        String sql = "SELECT TOP 1 invoice_id, contract_id, billing_month, billing_year, old_elec, new_elec, " +
                     "old_water, new_water, total_amount, payment_status " +
                     "FROM Invoices WHERE contract_id = ? " +
                     "ORDER BY billing_year DESC, billing_month DESC, invoice_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Invoice(
                        rs.getInt("invoice_id"),
                        rs.getInt("contract_id"),
                        rs.getInt("billing_month"),
                        rs.getInt("billing_year"),
                        rs.getInt("old_elec"),
                        rs.getInt("new_elec"),
                        rs.getInt("old_water"),
                        rs.getInt("new_water"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status")
                    );
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getLatestInvoiceByContractId", e);
        }
        return null;
    }

    /**
     * Check if invoice for contract and month/year already exists.
     */
    public boolean isInvoiceExist(int contractId, int month, int year) {
        String sql = "SELECT 1 FROM Invoices WHERE contract_id = ? AND billing_month = ? AND billing_year = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error isInvoiceExist", e);
        }
        return false;
    }

    /**
     * Insert a new Invoice.
     */
    public int insertInvoice(Invoice inv) {
        String sql = "INSERT INTO Invoices (contract_id, billing_month, billing_year, old_elec, new_elec, " +
                     "old_water, new_water, total_amount, payment_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, inv.getContractId());
            ps.setInt(2, inv.getBillingMonth());
            ps.setInt(3, inv.getBillingYear());
            ps.setInt(4, inv.getOldElec());
            ps.setInt(5, inv.getNewElec());
            ps.setInt(6, inv.getOldWater());
            ps.setInt(7, inv.getNewWater());
            ps.setBigDecimal(8, inv.getTotalAmount());
            ps.setString(9, inv.getPaymentStatus() != null ? inv.getPaymentStatus() : "UNPAID");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertInvoice", e);
        }
        return -1;
    }

    /**
     * Update payment status of an invoice.
     * When admin approves and marks PAID, existing PENDING transactions for this invoice are marked SUCCESS.
     * If no transaction existed, a CASH transaction is created.
     */
    public boolean updatePaymentStatus(int invoiceId, String status) {
        String sql = "UPDATE Invoices SET payment_status = ? WHERE invoice_id = ?";
        String sqlCheckTx = "SELECT COUNT(*) FROM Transactions WHERE invoice_id = ?";
        String sqlUpdateTx = "UPDATE Transactions SET status = 'SUCCESS' WHERE invoice_id = ? AND status = 'PENDING'";
        String sqlGetAmt = "SELECT total_amount FROM Invoices WHERE invoice_id = ?";
        String sqlInsertTx = "INSERT INTO Transactions (invoice_id, payment_method, amount, status) VALUES (?, 'CASH', ?, 'SUCCESS')";
        try (Connection conn = DBContext.getConnection()) {
            boolean updated;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, invoiceId);
                updated = ps.executeUpdate() > 0;
            }
            if (updated && "PAID".equalsIgnoreCase(status)) {
                // If there were pending transactions (e.g. from customer VietQR transfer), update them to SUCCESS
                int txCount = 0;
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckTx)) {
                    psCheck.setInt(1, invoiceId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) txCount = rs.getInt(1);
                    }
                }
                if (txCount > 0) {
                    try (PreparedStatement psUpTx = conn.prepareStatement(sqlUpdateTx)) {
                        psUpTx.setInt(1, invoiceId);
                        psUpTx.executeUpdate();
                    }
                } else {
                    BigDecimal amount = BigDecimal.ZERO;
                    try (PreparedStatement psAmt = conn.prepareStatement(sqlGetAmt)) {
                        psAmt.setInt(1, invoiceId);
                        try (ResultSet rs = psAmt.executeQuery()) {
                            if (rs.next()) {
                                amount = rs.getBigDecimal("total_amount");
                            }
                        }
                    }
                    try (PreparedStatement psTx = conn.prepareStatement(sqlInsertTx)) {
                        psTx.setInt(1, invoiceId);
                        psTx.setBigDecimal(2, amount);
                        psTx.executeUpdate();
                    }
                }
            }
            return updated;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updatePaymentStatus", e);
        }
        return false;
    }

    /**
     * Customer confirms payment for their own invoice: updates invoice status to PENDING and inserts a Transaction record with status PENDING.
     */
    public boolean payInvoiceByCustomer(int invoiceId, int userId, String paymentMethod) {
        String sqlCheck = "SELECT i.total_amount, i.payment_status FROM Invoices i " +
                          "JOIN Contracts c ON i.contract_id = c.contract_id " +
                          "WHERE i.invoice_id = ? AND c.user_id = ?";
        String sqlUpdate = "UPDATE Invoices SET payment_status = 'PENDING' WHERE invoice_id = ?";
        String sqlTx = "INSERT INTO Transactions (invoice_id, payment_method, amount, status) VALUES (?, ?, ?, 'PENDING')";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            BigDecimal amount = null;
            String currentStatus = null;
            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, invoiceId);
                psCheck.setInt(2, userId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        amount = rs.getBigDecimal("total_amount");
                        currentStatus = rs.getString("payment_status");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if ("PAID".equalsIgnoreCase(currentStatus) || "PENDING".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return true;
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setInt(1, invoiceId);
                psUpdate.executeUpdate();
            }

            try (PreparedStatement psTx = conn.prepareStatement(sqlTx)) {
                psTx.setInt(1, invoiceId);
                psTx.setString(2, paymentMethod != null ? paymentMethod : "VIETQR");
                psTx.setBigDecimal(3, amount != null ? amount : BigDecimal.ZERO);
                psTx.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Error payInvoiceByCustomer", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
        return false;
    }

    /**
     * Persist final settlement invoice and deposit-offset transaction when terminating a contract.
     */
    public int recordSettlementInvoice(int contractId, int month, int year,
                                       int oldElec, int newElec, int oldWater, int newWater,
                                       BigDecimal totalUsage) {
        String sqlFind = "SELECT invoice_id FROM Invoices WHERE contract_id = ? AND billing_month = ? AND billing_year = ?";
        String sqlUpdate = "UPDATE Invoices SET old_elec = ?, new_elec = ?, old_water = ?, new_water = ?, total_amount = ?, payment_status = 'PAID' WHERE invoice_id = ?";
        String sqlInsert = "INSERT INTO Invoices (contract_id, billing_month, billing_year, old_elec, new_elec, old_water, new_water, total_amount, payment_status) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PAID')";
        String sqlTx = "INSERT INTO Transactions (invoice_id, payment_method, amount, status) VALUES (?, 'DEPOSIT_OFFSET', ?, 'SUCCESS')";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            int invoiceId = -1;
            try (PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
                psFind.setInt(1, contractId);
                psFind.setInt(2, month);
                psFind.setInt(3, year);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        invoiceId = rs.getInt("invoice_id");
                    }
                }
            }

            if (invoiceId > 0) {
                try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                    psUpdate.setInt(1, oldElec);
                    psUpdate.setInt(2, newElec);
                    psUpdate.setInt(3, oldWater);
                    psUpdate.setInt(4, newWater);
                    psUpdate.setBigDecimal(5, totalUsage);
                    psUpdate.setInt(6, invoiceId);
                    psUpdate.executeUpdate();
                }
            } else {
                try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                    psInsert.setInt(1, contractId);
                    psInsert.setInt(2, month);
                    psInsert.setInt(3, year);
                    psInsert.setInt(4, oldElec);
                    psInsert.setInt(5, newElec);
                    psInsert.setInt(6, oldWater);
                    psInsert.setInt(7, newWater);
                    psInsert.setBigDecimal(8, totalUsage);
                    psInsert.executeUpdate();
                    try (ResultSet rs = psInsert.getGeneratedKeys()) {
                        if (rs.next()) {
                            invoiceId = rs.getInt(1);
                        }
                    }
                }
            }

            if (invoiceId > 0) {
                try (PreparedStatement psTx = conn.prepareStatement(sqlTx)) {
                    psTx.setInt(1, invoiceId);
                    psTx.setBigDecimal(2, totalUsage);
                    psTx.executeUpdate();
                }
            }

            conn.commit();
            return invoiceId;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Error recordSettlementInvoice", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
        return -1;
    }

    /**
     * Get monthly revenue statistics for the last 6 months.
     */
    public Map<String, BigDecimal> getRevenueLast6Months() {
        Map<String, BigDecimal> stats = new HashMap<>();
        String sql = "SELECT billing_month, billing_year, SUM(total_amount) AS revenue " +
                     "FROM Invoices " +
                     "WHERE payment_status = 'PAID' " +
                     "GROUP BY billing_year, billing_month " +
                     "ORDER BY billing_year DESC, billing_month DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int count = 0;
            while (rs.next() && count < 6) {
                String key = "T" + rs.getInt("billing_month") + "/" + rs.getInt("billing_year");
                stats.put(key, rs.getBigDecimal("revenue"));
                count++;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getRevenueLast6Months", e);
        }
        return stats;
    }

    /**
     * Get Dashboard KPI counters.
     */
    public Map<String, Object> getDashboardKPIs(int currentMonth, int currentYear) {
        Map<String, Object> kpis = new HashMap<>();

        // 1. Total paid revenue this month
        String sqlRevenue = "SELECT ISNULL(SUM(total_amount), 0) FROM Invoices WHERE billing_month = ? AND billing_year = ? AND payment_status = 'PAID'";
        // 2. Unpaid amount
        String sqlUnpaid = "SELECT ISNULL(SUM(total_amount), 0) FROM Invoices WHERE payment_status = 'UNPAID'";
        // 3. Count Available Rooms
        String sqlAvailableRooms = "SELECT COUNT(*) FROM Rooms WHERE status = 'AVAILABLE' AND is_active = 1";
        // 4. Count Occupied Rooms
        String sqlOccupiedRooms = "SELECT COUNT(*) FROM Rooms WHERE status = 'OCCUPIED' AND is_active = 1";
        // 5. Count Open Maintenance Tickets
        String sqlOpenTickets = "SELECT COUNT(*) FROM MaintenanceTickets WHERE status IN ('OPEN', 'PENDING')";

        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlRevenue)) {
                ps.setInt(1, currentMonth);
                ps.setInt(2, currentYear);
                try (ResultSet rs = ps.executeQuery()) {
                    kpis.put("currentMonthRevenue", rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlUnpaid);
                 ResultSet rs = ps.executeQuery()) {
                kpis.put("totalUnpaidAmount", rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO);
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlAvailableRooms);
                 ResultSet rs = ps.executeQuery()) {
                kpis.put("availableRoomsCount", rs.next() ? rs.getInt(1) : 0);
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlOccupiedRooms);
                 ResultSet rs = ps.executeQuery()) {
                kpis.put("occupiedRoomsCount", rs.next() ? rs.getInt(1) : 0);
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlOpenTickets);
                 ResultSet rs = ps.executeQuery()) {
                kpis.put("openTicketsCount", rs.next() ? rs.getInt(1) : 0);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getDashboardKPIs", e);
        }
        return kpis;
    }

    private Invoice mapResultSetToInvoice(ResultSet rs) throws SQLException {
        Invoice i = new Invoice();
        i.setInvoiceId(rs.getInt("invoice_id"));
        i.setContractId(rs.getInt("contract_id"));
        i.setBillingMonth(rs.getInt("billing_month"));
        i.setBillingYear(rs.getInt("billing_year"));
        i.setOldElec(rs.getInt("old_elec"));
        i.setNewElec(rs.getInt("new_elec"));
        i.setOldWater(rs.getInt("old_water"));
        i.setNewWater(rs.getInt("new_water"));
        i.setTotalAmount(rs.getBigDecimal("total_amount"));
        i.setPaymentStatus(rs.getString("payment_status"));

        Contract c = new Contract();
        c.setContractId(i.getContractId());
        c.setRoomId(rs.getInt("room_id"));
        c.setUserId(rs.getInt("user_id"));

        Room r = new Room();
        r.setRoomId(c.getRoomId());
        r.setRoomNumber(rs.getString("room_number"));
        c.setRoom(r);

        User u = new User();
        u.setUserId(c.getUserId());
        u.setFullName(rs.getString("full_name"));
        c.setUser(u);

        i.setContract(c);
        return i;
    }
}
