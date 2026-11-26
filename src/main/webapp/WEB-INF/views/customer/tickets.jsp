<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Yêu Cầu Báo Hỏng & Sửa Chữa" />
    <jsp:param name="activeNav" value="tickets" />
</jsp:include>

<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-slate-800 mb-1">Phiếu Báo Hỏng & Bảo Trì Thiết Bị</h4>
            <span class="text-muted small">Gửi yêu cầu sửa chữa điện thoại, nước, máy lạnh để chủ trọ kịp thời xử lý</span>
        </div>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${param.msg == 'TicketCreated'}">
        <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-check-circle me-2"></i>Phiếu báo hỏng đã được gửi thành công đến chủ trọ!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.msg == 'TicketCancelled'}">
        <div class="alert alert-info alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-info-circle me-2"></i>Đã hủy phiếu yêu cầu sửa chữa.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'NoActiveContract'}">
        <div class="alert alert-warning alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>Bạn hiện chưa có hợp đồng thuê phòng đang hiệu lực nên không thể gửi phiếu báo hỏng.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'InvalidInput' || param.error == 'CreateFailed' || param.error == 'CancelFailed'}">
        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-exclamation-circle me-2"></i>Không thể xử lý yêu cầu. Vui lòng kiểm tra lại thông tin và thử lại!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Cột trái: Form gửi phiếu mới -->
        <div class="col-12 col-lg-5">
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <h5 class="fw-bold text-slate-800 mb-3">
                    <i class="bi bi-plus-circle text-primary me-2"></i>Tạo Phiếu Báo Hỏng Mới
                </h5>
                <form action="${pageContext.request.contextPath}/customer/tickets" method="post">
                    <div class="mb-3">
                        <label for="title" class="form-label fw-semibold">Thiết bị / Sự cố cần sửa <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="title" name="title" placeholder="Ví dụ: Rò rỉ vòi nước, Máy lạnh không mát" required>
                    </div>

                    <div class="mb-3">
                        <label for="priority" class="form-label fw-semibold">Mức độ ưu tiên</label>
                        <select class="form-select" id="priority" name="priority">
                            <option value="LOW">Thấp (Chưa gấp)</option>
                            <option value="MEDIUM" selected>Trung bình (Nên xử lý trong 1-2 ngày)</option>
                            <option value="HIGH">Khẩn cấp (Mất điện, rò nước nặng...)</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label for="description" class="form-label fw-semibold">Mô tả chi tiết tình trạng</label>
                        <textarea class="form-control" id="description" name="description" rows="4" 
                                  placeholder="Mô tả cụ thể hiện tượng để thợ chuẩn bị dụng cụ phù hợp..."></textarea>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary py-2 fw-semibold">
                            <i class="bi bi-send me-1"></i> Gửi phiếu báo hỏng
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Cột phải: Bảng lịch sử các phiếu đã gửi -->
        <div class="col-12 col-lg-7">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-header bg-white py-3 px-4 border-bottom">
                    <h6 class="fw-bold mb-0 text-slate-800">Lịch Sử Phiếu Đã Gửi</h6>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Tiêu đề</th>
                                <th>Mức độ</th>
                                <th>Ngày gửi</th>
                                <th>Trạng thái</th>
                                <th class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${tickets}" var="t">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-slate-800">${t.title}</div>
                                        <small class="text-muted text-truncate d-inline-block" style="max-width: 200px;">${t.description}</small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.priority == 'HIGH'}"><span class="badge bg-danger-subtle text-danger">Khẩn cấp</span></c:when>
                                            <c:when test="${t.priority == 'MEDIUM'}"><span class="badge bg-warning-subtle text-warning-emphasis">Trung bình</span></c:when>
                                            <c:otherwise><span class="badge bg-secondary-subtle text-secondary">Thấp</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${t.createdDate}" pattern="dd/MM/yyyy HH:mm" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.status == 'OPEN'}">
                                                <span class="badge bg-danger bg-opacity-10 text-danger px-2 py-1">Đã tiếp nhận</span>
                                            </c:when>
                                            <c:when test="${t.status == 'IN_PROGRESS'}">
                                                <span class="badge bg-warning bg-opacity-10 text-warning px-2 py-1">Đang sửa chữa</span>
                                            </c:when>
                                            <c:when test="${t.status == 'RESOLVED'}">
                                                <span class="badge bg-success bg-opacity-10 text-success px-2 py-1">Đã sửa xong</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary bg-opacity-10 text-secondary px-2 py-1">Đã hủy</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <c:if test="${t.status == 'OPEN' || t.status == 'PENDING'}">
                                            <form action="${pageContext.request.contextPath}/customer/tickets/${t.ticketId}/cancel" method="post" class="d-inline">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" 
                                                        onclick="return confirm('Bạn có chắc muốn hủy phiếu báo hỏng này?');">
                                                    Hủy
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty tickets}">
                                <tr>
                                    <td colspan="5" class="text-center py-5 text-muted">
                                        <i class="bi bi-tools fs-1 d-block mb-2 text-secondary"></i>
                                        Bạn chưa gửi phiếu báo hỏng nào.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


