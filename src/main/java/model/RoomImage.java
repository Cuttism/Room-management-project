package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity representing the RoomImages table.
 */
public class RoomImage implements Serializable {
    private static final long serialVersionUID = 1L;

    private int imageId;
    private int roomId;
    private String imageUrl;
    private String region;
    private Timestamp createdDate;
    private String roomNumber;

    public RoomImage() {
    }

    public RoomImage(int imageId, int roomId, String imageUrl) {
        this.imageId = imageId;
        this.roomId = roomId;
        this.imageUrl = imageUrl;
    }

    public RoomImage(int imageId, int roomId, String imageUrl, String region, Timestamp createdDate) {
        this.imageId = imageId;
        this.roomId = roomId;
        this.imageUrl = imageUrl;
        this.region = region;
        this.createdDate = createdDate;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    @Override
    public String toString() {
        return "RoomImage{" +
                "imageId=" + imageId +
                ", roomId=" + roomId +
                ", imageUrl='" + imageUrl + '\'' +
                ", region='" + region + '\'' +
                ", createdDate=" + createdDate +
                '}';
    }
}
