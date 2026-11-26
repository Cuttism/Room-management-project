<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Hóa Đơn & Thu Phí" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="invoices" />
    <jsp:param name="pageTitle" value="Danh Sách Hóa Đơn Hàng Tháng" />
</jsp:include>

<!-- Header & Actions -->
<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Lịch Sử Hóa Đơn & Thu Phí</h5>
        <span class="text-muted small">Theo dõi trạng thái thanh toán, đối soát tiền mặt hoặc trực tuyến (VNPay / MoMo)</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/billing" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-lightning-charge-fill"></i>
            <span>Chốt điện nước tháng mới</span>
        </a>
    </div>
</div>

<!-- Notifications -->
<c:if test="${param.msg == 'BatchInvoicesCreated'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>
        Đã xử lý chốt điện nước hàng loạt:
        <strong>${not empty param.created ? param.created : 0}</strong> hóa đơn mới được tạo<c:if test="${not empty param.skipped and param.skipped > 0}">, bỏ qua <strong>${param.skipped}</strong> phòng đã có hóa đơn kỳ này</c:if><c:if test="${not empty param.invalid and param.invalid > 0}">, từ chối <strong>${param.invalid}</strong> dòng có chỉ số mới nhỏ hơn chỉ số cũ</c:if>.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.msg == 'StatusUpdated'}">
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <i class="bi bi-info-circle me-2"></i>Cập nhật trạng thái thanh toán của hóa đơn thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>Mã HĐ</th>
                    <th>Phòng</th>
                    <th>Khách thuê</th>
                    <th>Kỳ hóa đơn</th>
                    <th>Điện tiêu thụ</th>
                    <th>Nước tiêu thụ</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th class="text-end" style="width: 180px;">Cập nhật thu tiền</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${invoices}" var="inv">
                    <tr>
                        <td class="fw-semibold text-primary">#INV-${inv.invoiceId}</td>
                        <td>
                            <strong class="badge bg-light text-dark border px-2 py-1 fs-6">
                                P.${inv.contract.room.roomNumber}
                            </strong>
                        </td>
                        <td>${inv.contract.user.fullName}</td>
                        <td>
                            <span class="badge bg-secondary-subtle text-secondary px-2 py-1">
                                T${inv.billingMonth}/${inv.billingYear}
                            </span>
                        </td>
                        <td>
                            <div>${inv.newElec - inv.oldElec} kWh</div>
                            <small class="text-muted">(${inv.oldElec} &rarr; ${inv.newElec})</small>
                        </td>
                        <td>
                            <div>${inv.newWater - inv.oldWater} m³</div>
                            <small class="text-muted">(${inv.oldWater} &rarr; ${inv.newWater})</small>
                        </td>
                        <td class="fw-bold fs-6 text-slate-800">
                            <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###" /> đ
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${inv.paymentStatus == 'PAID'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">
                                        <i class="bi bi-check2-all me-1"></i>Đã thanh toán
                                    </span>
                                </c:when>
                                <c:when test="${inv.paymentStatus == 'PENDING'}">
                                    <span class="badge bg-warning bg-opacity-10 text-warning badge-status border border-warning-subtle">
                                        <i class="bi bi-hourglass-split me-1"></i>Đang chờ xác nhận
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger bg-opacity-10 text-danger badge-status">
                                        <i class="bi bi-clock-history me-1"></i>Chưa thanh toán
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <form action="${pageContext.request.contextPath}/admin/invoices/status" method="post" class="d-inline">
                                <input type="hidden" name="invoiceId" value="${inv.invoiceId}" />
                                <c:choose>
                                    <c:when test="${inv.paymentStatus == 'PAID'}">
                                        <input type="hidden" name="status" value="UNPAID" />
                                        <button type="submit" class="btn btn-sm btn-outline-secondary" title="Đánh dấu chưa thanh toán">
                                            <i class="bi bi-arrow-counterclockwise me-1"></i>Hoàn tác
                                        </button>
                                    </c:when>
                                    <c:when test="${inv.paymentStatus == 'PENDING'}">
                                        <input type="hidden" name="status" value="PAID" />
                                        <button type="submit" class="btn btn-sm btn-warning text-dark fw-bold" title="Xác nhận khách đã chuyển khoản">
                                            <i class="bi bi-check-circle me-1"></i>Duyệt thanh toán
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <input type="hidden" name="status" value="PAID" />
                                        <button type="submit" class="btn btn-sm btn-success fw-medium" title="Thu tiền mặt">
                                            <i class="bi bi-check-lg me-1"></i>Thu tiền
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty invoices}">
                    <tr>
                        <td colspan="9" class="text-center py-5 text-muted">
                            <i class="bi bi-receipt fs-1 d-block mb-2 text-secondary"></i>
                            Chưa có dữ liệu hóa đơn nào được tạo.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


