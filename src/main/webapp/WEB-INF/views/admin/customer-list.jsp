<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Tài Khoản & Khách Thuê" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="customers" />
    <jsp:param name="pageTitle" value="Danh Sách Tài Khoản & Khách Thuê" />
</jsp:include>

<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Quản Lý Khách Thuê & Tài Khoản</h5>
        <span class="text-muted small">Quản lý thông tin người dùng đã đăng ký, phân quyền và khóa/mở khóa tài khoản</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/customers/create" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-person-plus-fill"></i>
            <span>Thêm tài khoản mới</span>
        </a>
    </div>
</div>

<c:if test="${param.msg == 'CreatedSuccessfully'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Tạo tài khoản người dùng mới thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.msg == 'UpdatedSuccessfully'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Cập nhật thông tin tài khoản thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${param.msg == 'StatusUpdated'}">
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <i class="bi bi-info-circle me-2"></i>Đã cập nhật trạng thái hoạt động của tài khoản!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên đăng nhập</th>
                    <th>Họ và tên</th>
                    <th>Số điện thoại</th>
                    <th>Vai trò</th>
                    <th>Trạng thái</th>
                    <th class="text-end" style="width: 180px;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${users}" var="u">
                    <tr>
                        <td class="fw-semibold text-primary">#U-${u.userId}</td>
                        <td><code><c:out value="${u.username}" /></code></td>
                        <td class="fw-medium text-slate-800"><c:out value="${u.fullName}" /></td>
                        <td><i class="bi bi-telephone text-muted me-1"></i><c:out value="${u.phone}" /></td>
                        <td>
                            <c:choose>
                                <c:when test="${u.role == 'ADMIN'}">
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                        <i class="bi bi-shield-lock me-1"></i>Quản trị viên (ADMIN)
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-dark border px-2 py-1">
                                        <i class="bi bi-person me-1"></i>Khách thuê (CUSTOMER)
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${u.active}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">
                                        <i class="bi bi-check-circle-fill me-1"></i>Đang hoạt động
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger bg-opacity-10 text-danger badge-status">
                                        <i class="bi bi-lock-fill me-1"></i>Đã khóa
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <div class="d-inline-flex gap-1">
                                <a href="${pageContext.request.contextPath}/admin/customers/edit?id=${u.userId}"
                                   class="btn btn-sm btn-outline-secondary" title="Chỉnh sửa">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <c:if test="${sessionScope.currentUser.userId != u.userId}">
                                    <form action="${pageContext.request.contextPath}/admin/customers/toggle" method="post" class="d-inline">
                                        <input type="hidden" name="userId" value="${u.userId}" />
                                        <input type="hidden" name="active" value="${!u.active}" />
                                        <button type="submit" class="btn btn-sm ${u.active ? 'btn-outline-danger' : 'btn-outline-success'}"
                                                title="${u.active ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}">
                                            <i class="bi ${u.active ? 'bi-lock' : 'bi-unlock'}"></i>
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-people fs-1 d-block mb-2 text-secondary"></i>
                            Chưa có tài khoản người dùng nào trong hệ thống.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
