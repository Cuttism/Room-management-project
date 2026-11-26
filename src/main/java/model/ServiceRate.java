package model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entity representing the ServiceRates table.
 */
public class ServiceRate implements Serializable {
    private static final long serialVersionUID = 1L;

    private int rateId;
    private BigDecimal electricityPerKwh;
    private BigDecimal waterPerM3;
    private BigDecimal internetFee;
    private BigDecimal trashFee;

    public ServiceRate() {
    }

    public ServiceRate(int rateId, BigDecimal electricityPerKwh, BigDecimal waterPerM3, BigDecimal internetFee, BigDecimal trashFee) {
        this.rateId = rateId;
        this.electricityPerKwh = electricityPerKwh;
        this.waterPerM3 = waterPerM3;
        this.internetFee = internetFee;
        this.trashFee = trashFee;
    }

    public int getRateId() {
        return rateId;
    }

    public void setRateId(int rateId) {
        this.rateId = rateId;
    }

    public BigDecimal getElectricityPerKwh() {
        return electricityPerKwh;
    }

    public void setElectricityPerKwh(BigDecimal electricityPerKwh) {
        this.electricityPerKwh = electricityPerKwh;
    }

    public BigDecimal getWaterPerM3() {
        return waterPerM3;
    }

    public void setWaterPerM3(BigDecimal waterPerM3) {
        this.waterPerM3 = waterPerM3;
    }

    public BigDecimal getInternetFee() {
        return internetFee;
    }

    public void setInternetFee(BigDecimal internetFee) {
        this.internetFee = internetFee;
    }

    public BigDecimal getTrashFee() {
        return trashFee;
    }

    public void setTrashFee(BigDecimal trashFee) {
        this.trashFee = trashFee;
    }

    @Override
    public String toString() {
        return "ServiceRate{" +
                "rateId=" + rateId +
                ", electricityPerKwh=" + electricityPerKwh +
                ", waterPerM3=" + waterPerM3 +
                ", internetFee=" + internetFee +
                ", trashFee=" + trashFee +
                '}';
    }
}
