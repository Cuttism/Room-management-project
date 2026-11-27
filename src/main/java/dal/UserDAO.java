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
import util.PasswordUtil;

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
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users ORDER BY user_id DESC";
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
    public int insertUser(String email, String password, String fullName, String phone, String role, boolean isActive) {
        String sql = "INSERT INTO Users (email, password, full_name, phone, role, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hashPassword(password));
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
     * Update an existing User by Admin (optionally updating email and password if provided).
     */
    public boolean updateUser(int userId, String email, String fullName, String phone, String role, boolean isActive, String newPassword) {
        boolean changePass = (newPassword != null && !newPassword.trim().isEmpty());
        String sql = changePass
                ? "UPDATE Users SET email = ?, full_name = ?, phone = ?, role = ?, is_active = ?, password = ? WHERE user_id = ?"
                : "UPDATE Users SET email = ?, full_name = ?, phone = ?, role = ?, is_active = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            ps.setString(4, role);
            ps.setBoolean(5, isActive);
            if (changePass) {
                ps.setString(6, PasswordUtil.hashPassword(newPassword.trim()));
                ps.setInt(7, userId);
            } else {
                ps.setInt(6, userId);
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
                ps.setString(3, PasswordUtil.hashPassword(newPassword.trim()));
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
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users " +
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
     * Find user by email or phone number (for login).
     */
    public User getUserByEmailOrPhone(String identifier) {
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users WHERE email = ? OR phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getUserByEmailOrPhone", e);
        }
        return null;
    }

    /**
     * Find user by email.
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getUserByEmail", e);
        }
        return null;
    }

    /**
     * Find user by phone.
     */
    public User getUserByPhone(String phone) {
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users WHERE phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getUserByPhone", e);
        }
        return null;
    }

    /**
     * Find user by ID.
     */
    public User getUserById(int userId) {
        String sql = "SELECT user_id, email, password, full_name, phone, role, is_active FROM Users WHERE user_id = ?";
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
     * Insert new Customer during registration (password is hashed with PBKDF2 before storing).
     */
    public int insertCustomer(String fullName, String phone, String email, String password) {
        String sql = "INSERT INTO Users (email, password, full_name, phone, role, is_active) VALUES (?, ?, ?, ?, 'CUSTOMER', 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hashPassword(password));
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
            rs.getString("email"),
            rs.getString("password"),
            rs.getString("full_name"),
            rs.getString("phone"),
            rs.getString("role"),
            rs.getBoolean("is_active")
        );
    }
}
