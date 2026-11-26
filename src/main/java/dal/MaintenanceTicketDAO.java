package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.MaintenanceTicket;
import model.Room;
import model.User;

/**
 * Data Access Object for Maintenance Tickets.
 */
public class MaintenanceTicketDAO {
    private static final Logger LOGGER = Logger.getLogger(MaintenanceTicketDAO.class.getName());

    public List<MaintenanceTicket> getAllTickets() {
        List<MaintenanceTicket> list = new ArrayList<>();
        String sql = "SELECT t.ticket_id, t.room_id, t.user_id, t.title, t.description, t.priority, t.status, t.created_date, " +
                     "r.room_number, u.full_name, u.phone " +
                     "FROM MaintenanceTickets t " +
                     "JOIN Rooms r ON t.room_id = r.room_id " +
                     "JOIN Users u ON t.user_id = u.user_id " +
                     "ORDER BY t.created_date DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MaintenanceTicket ticket = new MaintenanceTicket(
                    rs.getInt("ticket_id"),
                    rs.getInt("room_id"),
                    rs.getInt("user_id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("priority"),
                    rs.getString("status"),
                    rs.getTimestamp("created_date")
                );

                Room r = new Room();
                r.setRoomId(ticket.getRoomId());
                r.setRoomNumber(rs.getString("room_number"));
                ticket.setRoom(r);

                User u = new User();
                u.setUserId(ticket.getUserId());
                u.setFullName(rs.getString("full_name"));
                u.setPhone(rs.getString("phone"));
                ticket.setUser(u);

                list.add(ticket);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllTickets", e);
        }
        return list;
    }

    public int insertTicket(int roomId, int userId, String title, String description, String priority) {
        String sql = "INSERT INTO MaintenanceTickets (room_id, user_id, title, description, priority, status) " +
                     "VALUES (?, ?, ?, ?, ?, 'OPEN')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, roomId);
            ps.setInt(2, userId);
            ps.setString(3, title);
            ps.setString(4, description);
            ps.setString(5, (priority != null && !priority.isEmpty()) ? priority : "MEDIUM");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertTicket", e);
        }
        return -1;
    }

    public boolean cancelCustomerTicket(int ticketId, int userId) {
        String sql = "UPDATE MaintenanceTickets SET status = 'CANCELLED' " +
                     "WHERE ticket_id = ? AND user_id = ? AND status IN ('OPEN', 'PENDING')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error cancelCustomerTicket", e);
        }
        return false;
    }

    public boolean updateTicketStatus(int ticketId, String status) {
        String sql = "UPDATE MaintenanceTickets SET status = ? WHERE ticket_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateTicketStatus", e);
        }
        return false;
    }
}
