<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Hóa Đơn & Thanh Toán Tiền Phòng" />
    <jsp:param name="activeNav" value="invoices" />
</jsp:include>

<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-slate-800 mb-1">Lịch Sử Hóa Đơn Tiền Phòng</h4>
            <span class="text-muted small">Chi tiết chỉ số điện, nước, các khoản phí và thanh toán trực tuyến qua VietQR</span>
        </div>
    </div>

    <!-- Alert / Notice -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger mb-4" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
        </div>
    </c:if>
    <c:if test="${param.msg == 'PaymentInitiated'}">
        <div class="alert alert-warning alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-hourglass-split me-2"></i>Đã ghi nhận yêu cầu thanh toán! Hóa đơn chuyển sang trạng thái <strong>Đang chờ xác nhận</strong>. Chủ trọ sẽ kiểm tra đối soát và phê duyệt cho bạn.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'PaymentFailed'}">
        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>Không thể xác nhận thanh toán cho hóa đơn này. Vui lòng thử lại!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Bảng danh sách hóa đơn -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Mã HĐ</th>
                                <th>Kỳ hóa đơn</th>
                                <th>Điện dùng</th>
                                <th>Nước dùng</th>
                                <th>Tổng thanh toán</th>
                                <th>Trạng thái</th>
                                <th class="text-end">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${invoices}" var="inv">
                                <tr>
                                    <td class="fw-semibold text-primary">#INV-${inv.invoiceId}</td>
                                    <td><strong>Tháng ${inv.billingMonth}/${inv.billingYear}</strong></td>
                                    <td>${inv.newElec - inv.oldElec} kWh</td>
                                    <td>${inv.newWater - inv.oldWater} m³</td>
                                    <td class="fw-bold text-slate-800">
                                        <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###" /> đ
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.paymentStatus == 'PAID'}">
                                                <span class="badge bg-success bg-opacity-10 text-success px-2 py-1">
                                                    <i class="bi bi-check2 me-1"></i>Đã thanh toán
                                                </span>
                                            </c:when>
                                            <c:when test="${inv.paymentStatus == 'PENDING'}">
                                                <span class="badge bg-warning bg-opacity-10 text-warning px-2 py-1 border border-warning-subtle">
                                                    <i class="bi bi-hourglass-split me-1"></i>Đang chờ xác nhận
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger bg-opacity-10 text-danger px-2 py-1">
                                                    <i class="bi bi-clock-history me-1"></i>Chưa thanh toán
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${inv.paymentStatus == 'PAID'}">
                                                <span class="text-muted small"><i class="bi bi-check-circle text-success me-1"></i>Hoàn tất</span>
                                            </c:when>
                                            <c:when test="${inv.paymentStatus == 'PENDING'}">
                                                <span class="text-muted small"><i class="bi bi-clock text-warning me-1"></i>Chờ chủ trọ duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn btn-sm btn-primary fw-medium" 
                                                        data-bs-toggle="modal" data-bs-target="#payModal_${inv.invoiceId}">
                                                    <i class="bi bi-qr-code me-1"></i> Thanh toán
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>

                                <!-- Modal Quét mã VietQR -->
                                <div class="modal fade" id="payModal_${inv.invoiceId}" tabindex="-1" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content rounded-4 border-0 shadow">
                                            <div class="modal-header border-0 pb-0">
                                                <h5 class="modal-title fw-bold">Thanh Toán Hóa Đơn #INV-${inv.invoiceId}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body text-center p-4">
                                                <p class="text-muted small mb-3">Mở ứng dụng Ngân hàng (MB, VCB, Techcombank...) hoặc MoMo quét mã QR dưới đây:</p>
                                                
                                                <!-- VietQR Image Mockup -->
                                                <div class="border p-3 rounded-3 d-inline-block bg-white shadow-sm mb-3">
                                                    <img src="https://api.vietqr.io/image/970422-0987654321-compact.jpg?amount=${inv.totalAmount}&addInfo=INV%20${inv.invoiceId}" 
                                                         alt="VietQR Payment" class="img-fluid rounded" style="max-width: 250px;">
                                                </div>

                                                <div class="fs-4 fw-bold text-primary mb-2">
                                                    <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###" /> VNĐ
                                                </div>
                                                <div class="small text-muted mb-4">Nội dung chuyển khoản: <code>INV ${inv.invoiceId}</code></div>

                                                <form action="${pageContext.request.contextPath}/customer/invoices/${inv.invoiceId}/pay" method="post">
                                                    <button type="submit" class="btn btn-success w-100 py-2 fw-semibold">
                                                        <i class="bi bi-shield-check me-1"></i> Tôi đã hoàn tất chuyển khoản
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty invoices}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-receipt fs-1 d-block mb-2 text-secondary"></i>
                                        Bạn chưa có hóa đơn thu phí nào.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Cột thông tin quy định -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <h6 class="fw-bold text-slate-800 mb-3"><i class="bi bi-credit-card-2-front text-primary me-2"></i>Hướng Dẫn Thanh Toán</h6>
                <ul class="small text-muted ps-3 mb-0" style="line-height: 1.8;">
                    <li>Hóa đơn tiền phòng được chốt từ ngày 25 đến 30 hàng tháng.</li>
                    <li>Khách thuê vui lòng thanh toán trong vòng 5 ngày kể từ ngày nhận hóa đơn.</li>
                    <li>Sau khi quét mã QR thành công, hệ thống sẽ tự động cập nhật trạng thái hoặc chủ trọ sẽ đối soát và đánh dấu <strong>Đã thanh toán</strong>.</li>
                </ul>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


