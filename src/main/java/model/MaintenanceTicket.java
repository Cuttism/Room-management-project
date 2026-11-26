package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity representing the MaintenanceTickets table.
 */
public class MaintenanceTicket implements Serializable {
    private static final long serialVersionUID = 1L;

    private int ticketId;
    private int roomId;
    private int userId;
    private String title;
    private String description;
    private String priority; // "LOW", "MEDIUM", "HIGH"
    private String status;   // "OPEN", "IN_PROGRESS", "RESOLVED", "CANCELLED"
    private Timestamp createdDate;

    // Optional reference objects for joins
    private Room room;
    private User user;

    public MaintenanceTicket() {
    }

    public MaintenanceTicket(int ticketId, int roomId, int userId, String title, String description, String priority, String status, Timestamp createdDate) {
        this.ticketId = ticketId;
        this.roomId = roomId;
        this.userId = userId;
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = status;
        this.createdDate = createdDate;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public String toString() {
        return "MaintenanceTicket{" +
                "ticketId=" + ticketId +
                ", roomId=" + roomId +
                ", userId=" + userId +
                ", title='" + title + '\'' +
                ", priority='" + priority + '\'' +
                ", status='" + status + '\'' +
                ", createdDate=" + createdDate +
                '}';
    }
}
