package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import model.User;

/**
 * Data Access Object for Users.
 */
public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    /**
     * Get all users (Admin & Customers) ordered by user_id DESC.
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, username, password, full_name, phone, role, is_active FROM Users ORDER BY user_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllUsers", e);
        }
        return list;
    }

    /**
     * Insert a new User with specified role and active status.
     */
    public int insertUser(String username, String password, String fullName, String phone, String role, boolean isActive) {
        String sql = "INSERT INTO Users (username, password, full_name, phone, role, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            ps.setString(5, (role != null && !role.isEmpty()) ? role : "CUSTOMER");
            ps.setBoolean(6, isActive);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertUser", e);
        }
        return -1;
    }

    /**
     * Update an existing User by Admin (optionally updating password if non-empty).
     */
    public boolean updateUser(int userId, String fullName, String phone, String role, boolean isActive, String newPassword) {
        boolean changePass = (newPassword != null && !newPassword.trim().isEmpty());
        String sql = changePass
                ? "UPDATE Users SET full_name = ?, phone = ?, role = ?, is_active = ?, password = ? WHERE user_id = ?"
                : "UPDATE Users SET full_name = ?, phone = ?, role = ?, is_active = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, role);
            ps.setBoolean(4, isActive);
            if (changePass) {
                ps.setString(5, newPassword.trim());
                ps.setInt(6, userId);
            } else {
                ps.setInt(5, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateUser", e);
        }
        return false;
    }

    /**
     * Update logged-in user's own profile (full name, phone, and optional password).
     */
    public boolean updateProfile(int userId, String fullName, String phone, String newPassword) {
        boolean changePass = (newPassword != null && !newPassword.trim().isEmpty());
        String sql = changePass
                ? "UPDATE Users SET full_name = ?, phone = ?, password = ? WHERE user_id = ?"
                : "UPDATE Users SET full_name = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            if (changePass) {
                ps.setString(3, newPassword.trim());
                ps.setInt(4, userId);
            } else {
                ps.setInt(3, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateProfile", e);
        }
        return false;
    }

    /**
     * Toggle user active status (lock/unlock account).
     */
    public boolean toggleUserActive(int userId, boolean isActive) {
        String sql = "UPDATE Users SET is_active = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggleUserActive", e);
        }
        return false;
    }

    /**
     * Get all active customers.
     */
    public List<User> getActiveCustomers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, username, password, full_name, phone, role, is_active FROM Users " +
                     "WHERE role = 'CUSTOMER' AND is_active = 1 ORDER BY full_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getActiveCustomers", e);
        }
        return list;
    }

    /**
     * Find user by username.
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT user_id, username, password, full_name, phone, role, is_active FROM Users WHERE username = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getUserByUsername", e);
        }
        return null;
    }

    /**
     * Find user by ID.
     */
    public User getUserById(int userId) {
        String sql = "SELECT user_id, username, password, full_name, phone, role, is_active FROM Users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getUserById", e);
        }
        return null;
    }

    /**
     * Insert new Customer quickly during Contract creation if not exists.
     */
    public int insertCustomer(String fullName, String phone, String username, String password) {
        String sql = "INSERT INTO Users (username, password, full_name, phone, role, is_active) VALUES (?, ?, ?, ?, 'CUSTOMER', 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertCustomer", e);
        }
        return -1;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("user_id"),
            rs.getString("username"),
            rs.getString("password"),
            rs.getString("full_name"),
            rs.getString("phone"),
            rs.getString("role"),
            rs.getBoolean("is_active")
        );
    }
}
