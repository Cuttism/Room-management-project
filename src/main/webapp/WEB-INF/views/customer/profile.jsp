<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Hồ Sơ Cá Nhân Của Tôi" />
    <jsp:param name="activeNav" value="profile" />
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-7">
            <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                    <div>
                        <h4 class="fw-bold text-slate-800 mb-1">Hồ Sơ Cá Nhân</h4>
                        <span class="text-muted small">Quản lý thông tin liên hệ và bảo mật tài khoản khách thuê</span>
                    </div>
                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2">
                        <i class="bi bi-person-check me-1"></i>Khách thuê
                    </span>
                </div>

                <c:if test="${param.msg == 'ProfileUpdated'}">
                    <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>Cập nhật thông tin tài khoản thành công!
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/customer/profile" method="post">
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
                            <input type="tel" class="form-control" id="phone" name="phone" value="<c:out value='${user.phone}'/>" required>
                        </div>
                    </div>

                    <h6 class="fw-bold text-slate-700 pb-2 mb-3 border-bottom">
                        <i class="bi bi-shield-lock me-1 text-primary"></i>Đổi Mật Khẩu (Để trống nếu giữ nguyên)
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
                        <a href="${pageContext.request.contextPath}/customer/contract" class="btn btn-light px-4">Quay lại</a>
                        <button type="submit" class="btn btn-primary px-4 fw-semibold">
                            <i class="bi bi-check2-circle me-1"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />
