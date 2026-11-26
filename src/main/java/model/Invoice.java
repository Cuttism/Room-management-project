package model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entity representing the Invoices table.
 */
public class Invoice implements Serializable {
    private static final long serialVersionUID = 1L;

    private int invoiceId;
    private int contractId;
    private int billingMonth;
    private int billingYear;
    private int oldElec;
    private int newElec;
    private int oldWater;
    private int newWater;
    private BigDecimal totalAmount;
    private String paymentStatus; // "UNPAID", "PAID", "OVERDUE"

    // Optional reference object for joins
    private Contract contract;

    public Invoice() {
    }

    public Invoice(int invoiceId, int contractId, int billingMonth, int billingYear, int oldElec, int newElec, int oldWater, int newWater, BigDecimal totalAmount, String paymentStatus) {
        this.invoiceId = invoiceId;
        this.contractId = contractId;
        this.billingMonth = billingMonth;
        this.billingYear = billingYear;
        this.oldElec = oldElec;
        this.newElec = newElec;
        this.oldWater = oldWater;
        this.newWater = newWater;
        this.totalAmount = totalAmount;
        this.paymentStatus = paymentStatus;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
    }

    public int getBillingMonth() {
        return billingMonth;
    }

    public void setBillingMonth(int billingMonth) {
        this.billingMonth = billingMonth;
    }

    public int getBillingYear() {
        return billingYear;
    }

    public void setBillingYear(int billingYear) {
        this.billingYear = billingYear;
    }

    public int getOldElec() {
        return oldElec;
    }

    public void setOldElec(int oldElec) {
        this.oldElec = oldElec;
    }

    public int getNewElec() {
        return newElec;
    }

    public void setNewElec(int newElec) {
        this.newElec = newElec;
    }

    public int getOldWater() {
        return oldWater;
    }

    public void setOldWater(int oldWater) {
        this.oldWater = oldWater;
    }

    public int getNewWater() {
        return newWater;
    }

    public void setNewWater(int newWater) {
        this.newWater = newWater;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public Contract getContract() {
        return contract;
    }

    public void setContract(Contract contract) {
        this.contract = contract;
    }

    public int getElecUsage() {
        return Math.max(0, newElec - oldElec);
    }

    public int getWaterUsage() {
        return Math.max(0, newWater - oldWater);
    }

    @Override
    public String toString() {
        return "Invoice{" +
                "invoiceId=" + invoiceId +
                ", contractId=" + contractId +
                ", billingMonth=" + billingMonth +
                ", billingYear=" + billingYear +
                ", totalAmount=" + totalAmount +
                ", paymentStatus='" + paymentStatus + '\'' +
                '}';
    }
}
