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
import model.Room;
import model.RoomImage;

/**
 * Data Access Object for Rooms and RoomImages.
 */
public class RoomDAO {
    private static final Logger LOGGER = Logger.getLogger(RoomDAO.class.getName());

    /**
     * Get all active rooms (optionally with images).
     */
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT room_id, room_number, base_price, status, max_occupants, amenities, description, is_active " +
                     "FROM Rooms WHERE is_active = 1 ORDER BY room_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Room r = mapResultSetToRoom(rs);
                r.setImages(getImagesByRoomId(r.getRoomId()));
                list.add(r);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getAllRooms", e);
        }
        return list;
    }

    /**
     * Get all rooms by status (e.g., 'AVAILABLE', 'OCCUPIED').
     */
    public List<Room> getRoomsByStatus(String status) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT room_id, room_number, base_price, status, max_occupants, amenities, description, is_active " +
                     "FROM Rooms WHERE is_active = 1 AND status = ? ORDER BY room_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room r = mapResultSetToRoom(rs);
                    r.setImages(getImagesByRoomId(r.getRoomId()));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getRoomsByStatus", e);
        }
        return list;
    }

    /**
     * Get Room by ID.
     */
    public Room getRoomById(int roomId) {
        String sql = "SELECT room_id, room_number, base_price, status, max_occupants, amenities, description, is_active " +
                     "FROM Rooms WHERE room_id = ? AND is_active = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Room room = mapResultSetToRoom(rs);
                    room.setImages(getImagesByRoomId(roomId));
                    return room;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getRoomById", e);
        }
        return null;
    }

    /**
     * Check if room number already exists (excluding a specific roomId for updates).
     */
    public boolean isRoomNumberExists(String roomNumber, int excludeRoomId) {
        String sql = "SELECT 1 FROM Rooms WHERE room_number = ? AND room_id != ? AND is_active = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNumber);
            ps.setInt(2, excludeRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error isRoomNumberExists", e);
        }
        return false;
    }

    /**
     * Insert a new Room and return the generated room_id.
     */
    public int insertRoom(Room room) {
        String sql = "INSERT INTO Rooms (room_number, base_price, status, max_occupants, amenities, description, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, room.getRoomNumber());
            ps.setBigDecimal(2, room.getBasePrice());
            ps.setString(3, room.getStatus() != null ? room.getStatus() : "AVAILABLE");
            ps.setInt(4, room.getMaxOccupants());
            ps.setString(5, room.getAmenities());
            ps.setString(6, room.getDescription());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertRoom", e);
        }
        return -1;
    }

    /**
     * Update room details.
     */
    public boolean updateRoom(Room room) {
        String sql = "UPDATE Rooms SET room_number = ?, base_price = ?, status = ?, max_occupants = ?, amenities = ?, description = ? " +
                     "WHERE room_id = ? AND is_active = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomNumber());
            ps.setBigDecimal(2, room.getBasePrice());
            ps.setString(3, room.getStatus());
            ps.setInt(4, room.getMaxOccupants());
            ps.setString(5, room.getAmenities());
            ps.setString(6, room.getDescription());
            ps.setInt(7, room.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateRoom", e);
        }
        return false;
    }

    /**
     * Soft delete room (is_active = 0).
     */
    public boolean softDeleteRoom(int roomId) {
        String sql = "UPDATE Rooms SET is_active = 0 WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error softDeleteRoom", e);
        }
        return false;
    }

    /**
     * Update room status directly (e.g. AVAILABLE, OCCUPIED).
     */
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE Rooms SET status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateRoomStatus", e);
        }
        return false;
    }

    /**
     * Insert batch images for a room with default region.
     */
    public void insertRoomImages(int roomId, List<String> imageUrls) {
        insertRoomImages(roomId, imageUrls, "Khu A - Tầng 1");
    }

    /**
     * Insert batch images for a room with a specified region.
     */
    public void insertRoomImages(int roomId, List<String> imageUrls, String region) {
        if (imageUrls == null || imageUrls.isEmpty()) return;
        String safeRegion = (region != null && !region.trim().isEmpty()) ? region.trim() : "Khu A - Tầng 1";
        String sql = "INSERT INTO RoomImages (room_id, image_url, region, created_date) VALUES (?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String url : imageUrls) {
                ps.setInt(1, roomId);
                ps.setString(2, url);
                ps.setString(3, safeRegion);
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error insertRoomImages", e);
        }
    }

    /**
     * Delete an image by image_id.
     */
    public boolean deleteRoomImage(int imageId) {
        String sql = "DELETE FROM RoomImages WHERE image_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleteRoomImage", e);
        }
        return false;
    }

    /**
     * Get images belonging to a room.
     */
    public List<RoomImage> getImagesByRoomId(int roomId) {
        List<RoomImage> list = new ArrayList<>();
        String sql = "SELECT image_id, room_id, image_url, region, created_date FROM RoomImages WHERE room_id = ? ORDER BY image_id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new RoomImage(
                        rs.getInt("image_id"),
                        rs.getInt("room_id"),
                        rs.getString("image_url"),
                        rs.getString("region"),
                        rs.getTimestamp("created_date")
                    ));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getImagesByRoomId", e);
        }
        return list;
    }

    /**
     * Get all unique images in the database library (deduplicated by image_url, ordered newest first).
     */
    public List<RoomImage> getLibraryImages() {
        List<RoomImage> list = new ArrayList<>();
        java.util.Set<String> seenUrls = new java.util.HashSet<>();
        String sql = "SELECT ri.image_id, ri.room_id, ri.image_url, ri.region, ri.created_date, r.room_number " +
                     "FROM RoomImages ri " +
                     "LEFT JOIN Rooms r ON ri.room_id = r.room_id " +
                     "ORDER BY ri.created_date DESC, ri.image_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String url = rs.getString("image_url");
                if (url != null && seenUrls.add(url)) {
                    RoomImage img = new RoomImage(
                        rs.getInt("image_id"),
                        rs.getInt("room_id"),
                        url,
                        rs.getString("region"),
                        rs.getTimestamp("created_date")
                    );
                    img.setRoomNumber(rs.getString("room_number"));
                    list.add(img);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getLibraryImages", e);
        }
        return list;
    }

    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        return new Room(
            rs.getInt("room_id"),
            rs.getString("room_number"),
            rs.getBigDecimal("base_price"),
            rs.getString("status"),
            rs.getInt("max_occupants"),
            rs.getString("amenities"),
            rs.getString("description"),
            rs.getBoolean("is_active")
        );
    }
}
