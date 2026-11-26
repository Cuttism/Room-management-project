package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing the Rooms table.
 */
public class Room implements Serializable {
    private static final long serialVersionUID = 1L;

    private int roomId;
    private String roomNumber;
    private BigDecimal basePrice;
    private String status; // "AVAILABLE", "OCCUPIED", "MAINTENANCE"
    private int maxOccupants;
    private String amenities;
    private String description;
    private boolean active;

    // Optional list of images for convenience
    private List<RoomImage> images = new ArrayList<>();

    public Room() {
    }

    public Room(int roomId, String roomNumber, BigDecimal basePrice, String status, int maxOccupants, String amenities, String description, boolean active) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.basePrice = basePrice;
        this.status = status;
        this.maxOccupants = maxOccupants;
        this.amenities = amenities;
        this.description = description;
        this.active = active;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getMaxOccupants() {
        return maxOccupants;
    }

    public void setMaxOccupants(int maxOccupants) {
        this.maxOccupants = maxOccupants;
    }

    public String getAmenities() {
        return amenities;
    }

    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public List<RoomImage> getImages() {
        return images;
    }

    public void setImages(List<RoomImage> images) {
        this.images = images;
    }

    @Override
    public String toString() {
        return "Room{" +
                "roomId=" + roomId +
                ", roomNumber='" + roomNumber + '\'' +
                ", basePrice=" + basePrice +
                ", status='" + status + '\'' +
                ", maxOccupants=" + maxOccupants +
                ", active=" + active +
                '}';
    }
}
