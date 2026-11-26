<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Thông Tin Hợp Đồng Của Tôi" />
    <jsp:param name="activeNav" value="contract" />
</jsp:include>

<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-slate-800 mb-1">Hợp Đồng Thuê Phòng Của Tôi</h4>
            <span class="text-muted small">Thông tin phòng đang ở, thời hạn hợp đồng và tiền cọc</span>
        </div>
        <c:if test="${contract != null}">
            <span class="badge bg-success px-3 py-2 fs-6"><i class="bi bi-shield-check me-1"></i>Hợp đồng đang có hiệu lực</span>
        </c:if>
    </div>

    <!-- Error/Notice Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-warning mb-4" role="alert">
            <i class="bi bi-info-circle me-2"></i>${errorMessage}
        </div>
    </c:if>

    <c:choose>
        <c:when test="${contract != null}">
            <div class="row g-4">
                <div class="col-12 col-lg-8">
                    <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                        <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                            <div>
                                <span class="text-muted small">Mã hợp đồng:</span>
                                <h5 class="fw-bold text-primary mb-0">#HD-${contract.contractId}</h5>
                            </div>
                            <span class="badge bg-light text-dark border px-3 py-2 fs-5">
                                Phòng ${contract.room.roomNumber}
                            </span>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-sm-6">
                                <span class="text-muted small d-block">Ngày bắt đầu thuê:</span>
                                <strong class="fs-6 text-slate-800">${contract.startDate}</strong>
                            </div>
                            <div class="col-sm-6">
                                <span class="text-muted small d-block">Ngày hết hạn hợp đồng:</span>
                                <strong class="fs-6 text-danger">${contract.endDate}</strong>
                            </div>
                            <div class="col-sm-6">
                                <span class="text-muted small d-block">Giá thuê hàng tháng:</span>
                                <strong class="fs-6 text-primary"><fmt:formatNumber value="${contract.room.basePrice}" pattern="#,###" /> đ</strong>
                            </div>
                            <div class="col-sm-6">
                                <span class="text-muted small d-block">Số tiền đã đặt cọc:</span>
                                <strong class="fs-6 text-success"><fmt:formatNumber value="${contract.depositAmount}" pattern="#,###" /> đ</strong>
                            </div>
                        </div>

                        <div class="bg-light p-3 rounded-3 border">
                            <h6 class="fw-bold text-slate-700 mb-2"><i class="bi bi-bell me-1 text-primary"></i> Quy định lưu ý:</h6>
                            <p class="small text-muted mb-0">
                                Tiền đặt cọc sẽ được hoàn trả hoặc cấn trừ công nợ điện nước cuối cùng khi quý khách thanh lý hợp đồng đúng hạn và bàn giao phòng nguyên vẹn.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-4">
                    <div class="card border-0 shadow-sm rounded-4 p-4 text-center">
                        <i class="bi bi-headset fs-1 text-primary mb-2"></i>
                        <h6 class="fw-bold text-slate-800">Cần Hỗ Trợ Kỹ Thuật?</h6>
                        <p class="small text-muted mb-4">Nếu thiết bị trong phòng gặp sự cố (máy lạnh, bóng đèn, điện nước), hãy gửi ngay phiếu báo hỏng.</p>
                        <a href="${pageContext.request.contextPath}/customer/tickets" class="btn btn-outline-primary fw-medium mb-2">
                            <i class="bi bi-tools me-1"></i> Báo hỏng thiết bị
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/invoices" class="btn btn-primary fw-medium">
                            <i class="bi bi-receipt me-1"></i> Xem hóa đơn tháng này
                        </a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card border-0 shadow-sm rounded-4 p-5 text-center">
                <i class="bi bi-file-earmark-x fs-1 text-muted mb-3 d-block"></i>
                <h5 class="fw-bold text-slate-700">Bạn hiện chưa có hợp đồng thuê phòng nào đang hoạt động.</h5>
                <p class="text-muted small mb-4">Vui lòng liên hệ với chủ trọ để kích hoạt hợp đồng thuê hoặc tìm kiếm phòng mới.</p>
                <div>
                    <a href="${pageContext.request.contextPath}/guest/rooms" class="btn btn-primary px-4">Xem danh sách phòng trống</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


