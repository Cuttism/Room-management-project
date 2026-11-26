<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Phiếu Báo Hỏng" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="tickets" />
    <jsp:param name="pageTitle" value="Danh Sách Yêu Cầu Sửa Chữa" />
</jsp:include>

<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Phiếu Báo Hỏng & Sửa Chữa</h5>
        <span class="text-muted small">Tiếp nhận và cập nhật tiến độ xử lý sự cố thiết bị từ khách thuê</span>
    </div>
</div>

<c:if test="${param.msg == 'Updated'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Đã cập nhật trạng thái phiếu bảo trì thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>Mã phiếu</th>
                    <th>Phòng</th>
                    <th>Người báo</th>
                    <th>Tiêu đề sự cố</th>
                    <th>Mức độ</th>
                    <th>Ngày gửi</th>
                    <th>Trạng thái</th>
                    <th class="text-end" style="width: 220px;">Xử lý</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${tickets}" var="t">
                    <tr>
                        <td class="fw-semibold text-primary">#TK-${t.ticketId}</td>
                        <td>
                            <strong class="badge bg-light text-dark border px-2 py-1 fs-6">P.${t.room.roomNumber}</strong>
                        </td>
                        <td>
                            <div class="fw-medium">${t.user.fullName}</div>
                            <small class="text-muted">${t.user.phone}</small>
                        </td>
                        <td>
                            <div class="fw-bold text-slate-800">${t.title}</div>
                            <small class="text-muted text-truncate d-inline-block" style="max-width: 220px;">${t.description}</small>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${t.priority == 'HIGH'}">
                                    <span class="badge bg-danger-subtle text-danger px-2 py-1">Khẩn cấp</span>
                                </c:when>
                                <c:when test="${t.priority == 'MEDIUM'}">
                                    <span class="badge bg-warning-subtle text-warning-emphasis px-2 py-1">Trung bình</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary-subtle text-secondary px-2 py-1">Thấp</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatDate value="${t.createdDate}" pattern="dd/MM/yyyy HH:mm" /></td>
                        <td>
                            <c:choose>
                                <c:when test="${t.status == 'OPEN'}">
                                    <span class="badge bg-danger bg-opacity-10 text-danger badge-status">Mới gửi</span>
                                </c:when>
                                <c:when test="${t.status == 'IN_PROGRESS'}">
                                    <span class="badge bg-warning bg-opacity-10 text-warning badge-status">Đang sửa</span>
                                </c:when>
                                <c:when test="${t.status == 'RESOLVED'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">Đã xong</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary bg-opacity-10 text-secondary badge-status">Đã hủy</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <form action="${pageContext.request.contextPath}/admin/tickets/status" method="post" class="d-flex gap-1 justify-content-end">
                                <input type="hidden" name="ticketId" value="${t.ticketId}" />
                                <select name="status" class="form-select form-select-sm" style="width: 130px;" onchange="this.form.submit()">
                                    <option value="OPEN" ${t.status == 'OPEN' ? 'selected' : ''}>Chờ duyệt</option>
                                    <option value="IN_PROGRESS" ${t.status == 'IN_PROGRESS' ? 'selected' : ''}>Đang sửa</option>
                                    <option value="RESOLVED" ${t.status == 'RESOLVED' ? 'selected' : ''}>Hoàn thành</option>
                                    <option value="CANCELLED" ${t.status == 'CANCELLED' ? 'selected' : ''}>Hủy bỏ</option>
                                </select>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty tickets}">
                    <tr>
                        <td colspan="8" class="text-center py-5 text-muted">
                            <i class="bi bi-check-circle fs-1 d-block mb-2 text-success"></i>
                            Hiện không có yêu cầu báo hỏng nào.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


