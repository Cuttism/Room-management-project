package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Contract;
import model.Room;
import model.User;

/**
 * Data Access Object for Contracts.
 */
public class ContractDAO {
    private static final Logger LOGGER = Logger.getLogger(ContractDAO.class.getName());

    /**
     * Get all contracts with Room and User details.
     */
    public List<Contract> getAllContracts() {
        List<Contract> list = new ArrayList<>();
        String sql = "SELECT c.contract_id, c.room_id, c.user_id, c.start_date, c.end_date, c.deposit_amount, c.actual_end_date, c.status, " +
                     "r.room_number, r.base_price, u.full_name, u.phone, u.username " +
                     "FROM Contracts c " +
                     "JOIN Rooms r ON c.room_id = r.room_id " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "ORDER BY c.contract_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToContract(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllContracts", e);
        }
        return list;
    }

    /**
     * Get all active contracts.
     */
    public List<Contract> getActiveContracts() {
        List<Contract> list = new ArrayList<>();
        String sql = "SELECT c.contract_id, c.room_id, c.user_id, c.start_date, c.end_date, c.deposit_amount, c.actual_end_date, c.status, " +
                     "r.room_number, r.base_price, u.full_name, u.phone, u.username " +
                     "FROM Contracts c " +
                     "JOIN Rooms r ON c.room_id = r.room_id " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "WHERE c.status = 'ACTIVE' " +
                     "ORDER BY r.room_number ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToContract(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getActiveContracts", e);
        }
        return list;
    }

    /**
     * Get Contract by ID.
     */
    public Contract getContractById(int contractId) {
        String sql = "SELECT c.contract_id, c.room_id, c.user_id, c.start_date, c.end_date, c.deposit_amount, c.actual_end_date, c.status, " +
                     "r.room_number, r.base_price, u.full_name, u.phone, u.username " +
                     "FROM Contracts c " +
                     "JOIN Rooms r ON c.room_id = r.room_id " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "WHERE c.contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToContract(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getContractById", e);
        }
        return null;
    }

    /**
     * Insert a new Contract and simultaneously update room status to 'OCCUPIED'.
     */
    public int createContract(Contract contract) {
        String sqlContract = "INSERT INTO Contracts (room_id, user_id, start_date, end_date, deposit_amount, status) " +
                             "VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
        String sqlRoom = "UPDATE Rooms SET status = 'OCCUPIED' WHERE room_id = ?";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            int generatedContractId = -1;
            try (PreparedStatement psContract = conn.prepareStatement(sqlContract, Statement.RETURN_GENERATED_KEYS)) {
                psContract.setInt(1, contract.getRoomId());
                psContract.setInt(2, contract.getUserId());
                psContract.setDate(3, contract.getStartDate());
                psContract.setDate(4, contract.getEndDate());
                psContract.setBigDecimal(5, contract.getDepositAmount());
                psContract.executeUpdate();

                try (ResultSet rs = psContract.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedContractId = rs.getInt(1);
                    }
                }
            }

            try (PreparedStatement psRoom = conn.prepareStatement(sqlRoom)) {
                psRoom.setInt(1, contract.getRoomId());
                psRoom.executeUpdate();
            }

            conn.commit();
            return generatedContractId;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Error createContract", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
        return -1;
    }

    /**
     * Terminate contract early or on due date, update actual_end_date and change Room status back to 'AVAILABLE'.
     */
    public boolean terminateContract(int contractId, int roomId, Date actualEndDate) {
        String sqlContract = "UPDATE Contracts SET status = 'TERMINATED', actual_end_date = ? WHERE contract_id = ?";
        String sqlRoom = "UPDATE Rooms SET status = 'AVAILABLE' WHERE room_id = ?";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sqlContract)) {
                ps.setDate(1, actualEndDate);
                ps.setInt(2, contractId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlRoom)) {
                ps.setInt(1, roomId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            LOGGER.log(Level.SEVERE, "Error terminateContract", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Close failed", ex); }
            }
        }
        return false;
    }

    private Contract mapResultSetToContract(ResultSet rs) throws SQLException {
        Contract c = new Contract();
        c.setContractId(rs.getInt("contract_id"));
        c.setRoomId(rs.getInt("room_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        c.setActualEndDate(rs.getDate("actual_end_date"));
        c.setStatus(rs.getString("status"));

        Room r = new Room();
        r.setRoomId(c.getRoomId());
        r.setRoomNumber(rs.getString("room_number"));
        r.setBasePrice(rs.getBigDecimal("base_price"));
        c.setRoom(r);

        User u = new User();
        u.setUserId(c.getUserId());
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setUsername(rs.getString("username"));
        c.setUser(u);

        return c;
    }
}
