package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;

/**
 * Entity representing the Contracts table.
 */
public class Contract implements Serializable {
    private static final long serialVersionUID = 1L;

    private int contractId;
    private int roomId;
    private int userId;
    private Date startDate;
    private Date endDate;
    private BigDecimal depositAmount;
    private Date actualEndDate;
    private String status; // "ACTIVE", "TERMINATED", "EXPIRED"

    // Optional reference objects for joins
    private Room room;
    private User user;

    public Contract() {
    }

    public Contract(int contractId, int roomId, int userId, Date startDate, Date endDate, BigDecimal depositAmount, Date actualEndDate, String status) {
        this.contractId = contractId;
        this.roomId = roomId;
        this.userId = userId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.depositAmount = depositAmount;
        this.actualEndDate = actualEndDate;
        this.status = status;
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
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

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public Date getActualEndDate() {
        return actualEndDate;
    }

    public void setActualEndDate(Date actualEndDate) {
        this.actualEndDate = actualEndDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
        return "Contract{" +
                "contractId=" + contractId +
                ", roomId=" + roomId +
                ", userId=" + userId +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", depositAmount=" + depositAmount +
                ", actualEndDate=" + actualEndDate +
                ", status='" + status + '\'' +
                '}';
    }
}
