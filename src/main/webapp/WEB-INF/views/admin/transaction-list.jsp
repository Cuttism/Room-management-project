<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Sử Giao Dịch Thanh Toán" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="transactions" />
    <jsp:param name="pageTitle" value="Nhật Ký Giao Dịch Thanh Toán" />
</jsp:include>

<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Lịch Sử Giao Dịch Thanh Toán</h5>
        <span class="text-muted small">Toàn bộ giao dịch VietQR, tiền mặt và cấn trừ tiền cọc được lưu trữ trong cơ sở dữ liệu</span>
    </div>
    <div>
        <a href="${pageContext.request.contextPath}/admin/invoices" class="btn btn-outline-primary btn-sm">
            <i class="bi bi-receipt me-1"></i> Xem danh sách hóa đơn
        </a>
    </div>
</div>

<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>Mã GD</th>
                    <th>Mã Hóa Đơn</th>
                    <th>Phòng</th>
                    <th>Khách thuê</th>
                    <th>Kỳ thu</th>
                    <th>Phương thức</th>
                    <th>Số tiền</th>
                    <th>Thời gian giao dịch</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${transactions}" var="tx">
                    <tr>
                        <td class="fw-semibold text-primary">#TX-${tx.transactionId}</td>
                        <td><code>#INV-${tx.invoiceId}</code></td>
                        <td><span class="badge bg-light text-dark border px-2 py-1">P.${tx.invoice.contract.room.roomNumber}</span></td>
                        <td class="fw-medium"><c:out value="${tx.invoice.contract.user.fullName}" /></td>
                        <td>T${tx.invoice.billingMonth}/${tx.invoice.billingYear}</td>
                        <td>
                            <c:choose>
                                <c:when test="${tx.paymentMethod == 'VIETQR'}">
                                    <span class="badge bg-primary-subtle text-primary px-2 py-1"><i class="bi bi-qr-code me-1"></i>VietQR</span>
                                </c:when>
                                <c:when test="${tx.paymentMethod == 'DEPOSIT_OFFSET'}">
                                    <span class="badge bg-info-subtle text-info-emphasis px-2 py-1"><i class="bi bi-arrow-left-right me-1"></i>Cấn trừ cọc</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary-subtle text-secondary px-2 py-1"><i class="bi bi-cash me-1"></i>Tiền mặt (${tx.paymentMethod})</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="fw-bold text-success">
                            <fmt:formatNumber value="${tx.amount}" pattern="#,###" /> đ
                        </td>
                        <td><fmt:formatDate value="${tx.transactionDate}" pattern="dd/MM/yyyy HH:mm:ss" /></td>
                        <td>
                            <c:choose>
                                <c:when test="${tx.status == 'SUCCESS'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">Thành công</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning bg-opacity-10 text-warning badge-status">${tx.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty transactions}">
                    <tr>
                        <td colspan="9" class="text-center py-5 text-muted">
                            <i class="bi bi-clock-history fs-1 d-block mb-2 text-secondary"></i>
                            Chưa có giao dịch thanh toán nào được ghi nhận.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
