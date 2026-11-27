<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Danh Sách Phòng" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="rooms" />
    <jsp:param name="pageTitle" value="Danh Sách Phòng Trọ" />
</jsp:include>

<!-- Header Action Row -->
<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Tất Cả Phòng Trọ</h5>
        <span class="text-muted small">Quản lý trạng thái, giá thuê và hình ảnh phòng trọ</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/rooms/create" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-plus-lg"></i>
            <span>Thêm phòng mới</span>
        </a>
    </div>
</div>

<!-- Notification messages -->
<c:if test="${param.msg == 'CreatedSuccessfully'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Thêm phòng trọ mới thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.msg == 'UpdatedSuccessfully'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Cập nhật thông tin phòng thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.msg == 'DeletedSuccessfully'}">
    <div class="alert alert-warning alert-dismissible fade show" role="alert">
        <i class="bi bi-trash me-2"></i>Đã xóa (Soft Delete) phòng thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.error == 'RoomOccupiedCannotDelete'}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Bị chặn bởi ràng buộc hợp đồng:</strong> Không thể xóa phòng này vì đang có hợp đồng thuê còn hiệu lực (ACTIVE). Vui lòng thanh lý hợp đồng trước khi xóa phòng!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.error == 'RoomNotFound'}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-circle me-2"></i>Không tìm thấy thông tin phòng trọ yêu cầu!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<!-- Room Table Card -->
<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th style="width: 110px;">Hình ảnh</th>
                    <th>Số phòng</th>
                    <th>Giá thuê cơ bản</th>
                    <th>Sức chứa</th>
                    <th>Tiện ích nổi bật</th>
                    <th>Trạng thái</th>
                    <th class="text-end" style="width: 140px;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${rooms}" var="r">
                    <tr>
                        <td>
                            <c:choose>
                                <c:when test="${not empty r.images}">
                                    <img src="${pageContext.request.contextPath}/${r.images[0].imageUrl}" 
                                         alt="Room ${r.roomNumber}" 
                                         class="rounded object-fit-cover shadow-sm" 
                                         style="width: 75px; height: 50px;">
                                </c:when>
                                <c:otherwise>
                                    <div class="rounded bg-light d-flex align-items-center justify-content-center text-muted border" 
                                         style="width: 75px; height: 50px;">
                                        <i class="bi bi-image fs-5"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <strong class="text-slate-800 fs-6">Phòng ${r.roomNumber}</strong>
                            <div class="text-muted small">${r.images.size()} hình ảnh</div>
                        </td>
                        <td class="fw-bold text-primary">
                            <fmt:formatNumber value="${r.basePrice}" pattern="#,###" /> <small>đ/tháng</small>
                        </td>
                        <td>
                            <i class="bi bi-person text-secondary me-1"></i>${r.maxOccupants} người
                        </td>
                        <td>
                            <span class="text-truncate d-inline-block small text-muted" style="max-width: 250px;">
                                ${not empty r.amenities ? r.amenities : "Chưa cập nhật"}
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${r.status == 'AVAILABLE'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">
                                        <i class="bi bi-check-circle-fill me-1"></i>Còn trống
                                    </span>
                                </c:when>
                                <c:when test="${r.status == 'OCCUPIED'}">
                                    <span class="badge bg-primary bg-opacity-10 text-primary badge-status">
                                        <i class="bi bi-person-fill me-1"></i>Đang thuê
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning bg-opacity-10 text-warning badge-status">
                                        <i class="bi bi-tools me-1"></i>Đang sửa chữa
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <div class="btn-group btn-group-sm">
                                <a href="${pageContext.request.contextPath}/admin/rooms/edit?id=${r.roomId}" 
                                   class="btn btn-outline-secondary" title="Chỉnh sửa">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/rooms/delete?id=${r.roomId}" 
                                   class="btn btn-outline-danger" 
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa phòng ${r.roomNumber}? (Bảo toàn dữ liệu Soft Delete)');" 
                                   title="Xóa phòng">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty rooms}">
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-door-closed fs-1 d-block mb-2 text-secondary"></i>
                            Hiện chưa có dữ liệu phòng trọ nào. Hãy nhấn "Thêm phòng mới".
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


