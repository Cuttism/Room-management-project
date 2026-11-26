<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Chốt Điện Nước Hàng Loạt" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="billing" />
    <jsp:param name="pageTitle" value="Ghi Số Điện Nước & Tự Động Tạo Hóa Đơn" />
</jsp:include>

<!-- Header & Filter Row -->
<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">
            <i class="bi bi-lightning-charge-fill text-warning me-2"></i>
            Chốt Chỉ Số Điện Nước - Tháng ${billingMonth}/${billingYear}
        </h5>
        <span class="text-muted small">Nhập chỉ số mới cho tất cả các phòng đang có khách thuê chỉ trên một màn hình duy nhất</span>
    </div>
    <div class="d-flex align-items-center gap-3 bg-white p-2 rounded-3 border">
        <span class="small text-muted"><i class="bi bi-info-circle me-1 text-primary"></i> Đơn giá áp dụng:</span>
        <span class="badge bg-light text-dark border">Điện: <strong><fmt:formatNumber value="${rates.electricityPerKwh}" pattern="#,###" />đ</strong>/kWh</span>
        <span class="badge bg-light text-dark border">Nước: <strong><fmt:formatNumber value="${rates.waterPerM3}" pattern="#,###" />đ</strong>/m³</span>
    </div>
</div>

<form action="${pageContext.request.contextPath}/admin/billing/batch-save" method="post" id="batchBillingForm">
    <input type="hidden" name="billingMonth" value="${billingMonth}" />
    <input type="hidden" name="billingYear" value="${billingYear}" />

    <div class="card-custom mb-4">
        <div class="table-responsive">
            <table class="table table-custom table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width: 100px;">Phòng</th>
                        <th>Khách thuê</th>
                        <th>Giá phòng</th>
                        <th style="width: 130px;">Số điện CŨ</th>
                        <th style="width: 160px;">Số điện MỚI (kWh)</th>
                        <th style="width: 130px;">Số nước CŨ</th>
                        <th style="width: 160px;">Số nước MỚI (m³)</th>
                        <th class="text-end" style="width: 160px;">Dự tính tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${contracts}" var="c">
                        <c:set var="lastInv" value="${latestInvoices[c.contractId]}" />
                        <c:set var="isBilled" value="${alreadyBilledMap[c.contractId]}" />
                        <c:set var="oldE" value="${lastInv != null ? lastInv.newElec : 0}" />
                        <c:set var="oldW" value="${lastInv != null ? lastInv.newWater : 0}" />

                        <tr data-contract-id="${c.contractId}" data-room-price="${c.room.basePrice}" class="${isBilled ? 'table-light' : ''}">
                            <input type="hidden" name="contractId" value="${c.contractId}" />
                            <input type="hidden" name="oldElec_${c.contractId}" value="${oldE}" />
                            <input type="hidden" name="oldWater_${c.contractId}" value="${oldW}" />

                            <td>
                                <strong class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle fs-6 px-3 py-1">
                                    P.${c.room.roomNumber}
                                </strong>
                                <c:if test="${isBilled}">
                                    <div class="mt-1">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle">Đã chốt T${billingMonth}</span>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <div class="fw-medium text-slate-800">${c.user.fullName}</div>
                                <small class="text-muted">${c.user.phone}</small>
                            </td>
                            <td class="text-muted">
                                <fmt:formatNumber value="${c.room.basePrice}" pattern="#,###" /> đ
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border px-2 py-1">${oldE}</span>
                            </td>
                            <td>
                                <input type="number" min="${oldE}" class="form-control form-control-sm input-new-elec" 
                                       name="newElec_${c.contractId}" 
                                       placeholder="${isBilled ? 'Đã lập HĐ' : '>= '.concat(oldE)}"
                                       ${isBilled ? 'disabled' : 'required'}>
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border px-2 py-1">${oldW}</span>
                            </td>
                            <td>
                                <input type="number" min="${oldW}" class="form-control form-control-sm input-new-water" 
                                       name="newWater_${c.contractId}" 
                                       placeholder="${isBilled ? 'Đã lập HĐ' : '>= '.concat(oldW)}"
                                       ${isBilled ? 'disabled' : 'required'}>
                            </td>
                            <td class="text-end fw-bold text-primary est-total">
                                <fmt:formatNumber value="${c.room.basePrice + rates.internetFee + rates.trashFee}" pattern="#,###" /> đ
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty contracts}">
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                Hiện tại không có phòng nào đang có hợp đồng hoạt động để ghi điện nước.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${not empty contracts}">
        <div class="d-flex justify-content-between align-items-center bg-white p-3 rounded-3 card-custom">
            <span class="text-muted small">
                <i class="bi bi-check2-circle text-success me-1"></i>
                Hóa đơn tháng ${billingMonth}/${billingYear} sẽ tự động được gửi và xuất hiện trên cổng của từng khách thuê.
            </span>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/invoices" class="btn btn-outline-secondary">Xem lịch sử hóa đơn</a>
                <button type="submit" class="btn btn-primary px-4 fw-medium">
                    <i class="bi bi-save me-1"></i> Lưu & Tự động tạo hóa đơn hàng loạt
                </button>
            </div>
        </div>
    </c:if>
</form>

<!-- Dynamic instant calculation for preview total -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const elecRate = ${rates.electricityPerKwh};
        const waterRate = ${rates.waterPerM3};
        const extraFee = ${rates.internetFee + rates.trashFee};

        const rows = document.querySelectorAll("tr[data-contract-id]");
        rows.forEach(row => {
            const basePrice = parseFloat(row.getAttribute("data-room-price")) || 0;
            const oldElec = parseInt(row.querySelector("input[name^='oldElec_']").value) || 0;
            const oldWater = parseInt(row.querySelector("input[name^='oldWater_']").value) || 0;
            const newElecInput = row.querySelector(".input-new-elec");
            const newWaterInput = row.querySelector(".input-new-water");
            const totalDisplay = row.querySelector(".est-total");

            function updateTotal() {
                const newElec = parseInt(newElecInput.value) || oldElec;
                const newWater = parseInt(newWaterInput.value) || oldWater;

                const elecCount = Math.max(0, newElec - oldElec);
                const waterCount = Math.max(0, newWater - oldWater);

                const total = basePrice + extraFee + (elecCount * elecRate) + (waterCount * waterRate);
                totalDisplay.innerText = new Intl.NumberFormat('vi-VN').format(total) + " đ";
            }

            newElecInput.addEventListener("input", updateTotal);
            newWaterInput.addEventListener("input", updateTotal);
        });
    });
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


