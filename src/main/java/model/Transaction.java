package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity representing the Transactions table.
 */
public class Transaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private int transactionId;
    private int invoiceId;
    private String paymentMethod; // "VNPAY", "MOMO", "VIETQR", "CASH"
    private BigDecimal amount;
    private Timestamp transactionDate;
    private String status; // "PENDING", "SUCCESS", "FAILED"

    // Optional reference object
    private Invoice invoice;

    public Transaction() {
    }

    public Transaction(int transactionId, int invoiceId, String paymentMethod, BigDecimal amount, Timestamp transactionDate, String status) {
        this.transactionId = transactionId;
        this.invoiceId = invoiceId;
        this.paymentMethod = paymentMethod;
        this.amount = amount;
        this.transactionDate = transactionDate;
        this.status = status;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Invoice getInvoice() {
        return invoice;
    }

    public void setInvoice(Invoice invoice) {
        this.invoice = invoice;
    }

    @Override
    public String toString() {
        return "Transaction{" +
                "transactionId=" + transactionId +
                ", invoiceId=" + invoiceId +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", amount=" + amount +
                ", transactionDate=" + transactionDate +
                ", status='" + status + '\'' +
                '}';
    }
}
