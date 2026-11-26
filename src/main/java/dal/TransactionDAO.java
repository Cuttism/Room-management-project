package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Contract;
import model.Invoice;
import model.Room;
import model.Transaction;
import model.User;

/**
 * Data Access Object for Transactions table.
 */
public class TransactionDAO {
    private static final Logger LOGGER = Logger.getLogger(TransactionDAO.class.getName());

    /**
     * Get all transactions with invoice, contract, room, and user details.
     */
    public List<Transaction> getAllTransactions() {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT tx.transaction_id, tx.invoice_id, tx.payment_method, tx.amount, tx.transaction_date, tx.status, " +
                     "i.billing_month, i.billing_year, i.total_amount, i.payment_status, " +
                     "c.contract_id, c.room_id, c.user_id, " +
                     "r.room_number, u.full_name, u.phone " +
                     "FROM Transactions tx " +
                     "JOIN Invoices i ON tx.invoice_id = i.invoice_id " +
                     "JOIN Contracts c ON i.contract_id = c.contract_id " +
                     "JOIN Rooms r ON c.room_id = r.room_id " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "ORDER BY tx.transaction_date DESC, tx.transaction_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Transaction tx = new Transaction(
                    rs.getInt("transaction_id"),
                    rs.getInt("invoice_id"),
                    rs.getString("payment_method"),
                    rs.getBigDecimal("amount"),
                    rs.getTimestamp("transaction_date"),
                    rs.getString("status")
                );

                Invoice inv = new Invoice();
                inv.setInvoiceId(tx.getInvoiceId());
                inv.setContractId(rs.getInt("contract_id"));
                inv.setBillingMonth(rs.getInt("billing_month"));
                inv.setBillingYear(rs.getInt("billing_year"));
                inv.setTotalAmount(rs.getBigDecimal("total_amount"));
                inv.setPaymentStatus(rs.getString("payment_status"));

                Contract c = new Contract();
                c.setContractId(inv.getContractId());
                c.setRoomId(rs.getInt("room_id"));
                c.setUserId(rs.getInt("user_id"));

                Room r = new Room();
                r.setRoomId(c.getRoomId());
                r.setRoomNumber(rs.getString("room_number"));
                c.setRoom(r);

                User u = new User();
                u.setUserId(c.getUserId());
                u.setFullName(rs.getString("full_name"));
                u.setPhone(rs.getString("phone"));
                c.setUser(u);

                inv.setContract(c);
                tx.setInvoice(inv);
                list.add(tx);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllTransactions", e);
        }
        return list;
    }
}
