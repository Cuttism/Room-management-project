<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Thanh Lý Hợp Đồng Thuê" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="contracts" />
    <jsp:param name="pageTitle" value="Thanh Lý Hợp Đồng & Cấn Trừ Tiền Cọc" />
</jsp:include>

<div class="row justify-content-center">
    <div class="col-12 col-lg-9">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <div>
                    <h5 class="fw-bold mb-1 text-danger">
                        <i class="bi bi-box-arrow-right me-2"></i>
                        Thanh Lý Hợp Đồng #HD-${contract.contractId} (Phòng ${contract.room.roomNumber})
                    </h5>
                    <small class="text-muted">Tính tiền phòng lẻ ngày, chốt chỉ số điện nước cuối cùng và cấn trừ vào số tiền cọc</small>
                </div>
                <a href="${pageContext.request.contextPath}/admin/contracts" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Trở về
                </a>
            </div>

            <!-- Contract overview card -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="bg-light rounded p-3 mb-4 border">
                <div class="row g-3">
                    <div class="col-sm-4">
                        <span class="text-muted small d-block">Khách thuê:</span>
                        <strong class="text-slate-800">${contract.user.fullName} (${contract.user.phone})</strong>
                    </div>
                    <div class="col-sm-4">
                        <span class="text-muted small d-block">Giá phòng cơ bản:</span>
                        <strong class="text-primary"><fmt:formatNumber value="${contract.room.basePrice}" pattern="#,###" /> đ/tháng</strong>
                    </div>
                    <div class="col-sm-4">
                        <span class="text-muted small d-block">Tiền cọc ban đầu:</span>
                        <strong class="text-success fs-6"><fmt:formatNumber value="${contract.depositAmount}" pattern="#,###" /> đ</strong>
                    </div>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/admin/contracts/terminate" method="post" id="terminateForm">
                <input type="hidden" name="contractId" value="${contract.contractId}" />
                <input type="hidden" name="roomId" value="${contract.roomId}" />

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label for="actualEndDate" class="form-label fw-semibold">Ngày trả phòng thực tế <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="actualEndDate" name="actualEndDate" required>
                    </div>

                    <div class="col-md-4">
                        <label for="finalElec" class="form-label fw-semibold">Chỉ số điện chốt cuối (kWh) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="finalElec" name="finalElec" 
                               value="${latestInvoice != null ? latestInvoice.newElec : 0}" required>
                        <div class="form-text">Số cũ: <strong>${latestInvoice != null ? latestInvoice.newElec : 0}</strong> kWh (${rates.electricityPerKwh} đ/kWh)</div>
                    </div>

                    <div class="col-md-4">
                        <label for="finalWater" class="form-label fw-semibold">Chỉ số nước chốt cuối (m³) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="finalWater" name="finalWater" 
                               value="${latestInvoice != null ? latestInvoice.newWater : 0}" required>
                        <div class="form-text">Số cũ: <strong>${latestInvoice != null ? latestInvoice.newWater : 0}</strong> m³ (${rates.waterPerM3} đ/m³)</div>
                    </div>
                </div>

                <!-- Settlement Breakdown Box -->
                <div class="card border-danger border-opacity-25 bg-danger bg-opacity-10 p-3 mb-4 rounded-3">
                    <h6 class="fw-bold text-danger mb-2"><i class="bi bi-calculator me-1"></i> Quy trình cấn trừ tiền cọc & Thanh toán:</h6>
                    <ul class="small mb-0 text-slate-700">
                        <li>Hệ thống tính tiền phòng lẻ ngày dựa trên ngày trả phòng thực tế.</li>
                        <li>Cộng tiền điện & tiền nước tiêu thụ cuối cùng + phí dịch vụ cố định (rác, internet).</li>
                        <li><strong>Công thức hoàn tiền cọc:</strong> <code>Tiền hoàn trả cho khách = Tiền cọc - Tổng chi phí tiêu thụ</code></li>
                        <li>Sau khi bấm xác nhận, phòng <strong>P.${contract.room.roomNumber}</strong> sẽ tự động chuyển về trạng thái <strong>Còn trống (AVAILABLE)</strong> để sẵn sàng cho khách mới.</li>
                    </ul>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/admin/contracts" class="btn btn-light px-4">Hủy thao tác</a>
                    <button type="submit" class="btn btn-danger px-4 fw-medium" 
                            onclick="return confirm('Bạn có chắc chắn muốn thanh lý hợp đồng và cấn trừ tiền cọc ngay bây giờ?');">
                        <i class="bi bi-check-circle me-1"></i> Xác nhận thanh lý & Cấn trừ cọc
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const today = new Date().toISOString().split('T')[0];
        const dateInput = document.getElementById('actualEndDate');
        if (dateInput && !dateInput.value) dateInput.value = today;
    });
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


