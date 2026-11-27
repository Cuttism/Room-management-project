<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Hồ Sơ Cá Nhân Quản Trị Viên" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="profile" />
    <jsp:param name="pageTitle" value="Hồ Sơ Cá Nhân & Đổi Mật Khẩu" />
</jsp:include>

<div class="row justify-content-center">
    <div class="col-12 col-lg-7">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <div>
                    <h5 class="fw-bold mb-1 text-slate-800">
                        <i class="bi bi-person-badge text-primary me-2"></i>
                        Thông Tin Tài Khoản Cá Nhân
                    </h5>
                    <span class="text-muted small">Cập nhật họ tên, số điện thoại liên hệ và mật khẩu đăng nhập</span>
                </div>
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">
                    ${user.role}
                </span>
            </div>

            <c:if test="${param.msg == 'ProfileUpdated'}">
                <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>Đã lưu thông tin hồ sơ vào cơ sở dữ liệu thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/profile" method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Địa chỉ Email</label>
                    <input type="email" class="form-control bg-light" value="<c:out value='${user.email}'/>" readonly>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label for="fullName" class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName" value="<c:out value='${user.fullName}'/>" required>
                    </div>
                    <div class="col-md-6">
                        <label for="phone" class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="phone" name="phone" value="<c:out value='${user.phone}'/>" required>
                    </div>
                </div>

                <h6 class="fw-bold text-slate-700 pb-2 mb-3 border-bottom">
                    <i class="bi bi-key me-1 text-warning"></i>Đổi Mật Khẩu (Để trống nếu không đổi)
                </h6>

                <div class="mb-3">
                    <label for="currentPassword" class="form-label fw-semibold">Mật khẩu hiện tại</label>
                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" placeholder="Nhập mật khẩu hiện tại">
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label for="newPassword" class="form-label fw-semibold">Mật khẩu mới</label>
                        <input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="Tối thiểu 6 ký tự">
                    </div>
                    <div class="col-md-6">
                        <label for="confirmPassword" class="form-label fw-semibold">Xác nhận mật khẩu mới</label>
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới">
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <button type="submit" class="btn btn-primary px-4 fw-medium">
                        <i class="bi bi-save me-1"></i> Lưu hồ sơ cá nhân
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
