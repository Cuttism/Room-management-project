<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Đăng Nhập Hệ Thống" />
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-6 col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                <div class="text-center mb-4">
                    <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-box-arrow-in-right fs-2"></i>
                    </div>
                    <h4 class="fw-bold text-slate-800">Đăng Nhập</h4>
                    <p class="text-muted small">Chào mừng bạn quay lại hệ thống quản lý nhà trọ</p>
                </div>

                <!-- Success Alert -->
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show mb-4 small" role="alert">
                        <i class="bi bi-check-circle-fill me-1"></i>${successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Error Alert -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4 small" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i>${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="mb-3">
                        <label for="username" class="form-label fw-semibold">Tên đăng nhập <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white text-muted"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control" id="username" name="username" 
                                   value="${enteredUsername}" placeholder="Nhập tên đăng nhập" required>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label for="password" class="form-label fw-semibold mb-0">Mật khẩu <span class="text-danger">*</span></label>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text bg-white text-muted"><i class="bi bi-lock"></i></span>
                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required>
                        </div>
                    </div>

                    <div class="d-grid mb-3">
                        <button type="submit" class="btn btn-primary btn-lg fw-bold">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập
                        </button>
                    </div>

                    <div class="text-center small text-muted">
                        Chưa có tài khoản? <a href="${pageContext.request.contextPath}/guest/register" class="text-primary fw-semibold text-decoration-none">Đăng ký ngay</a>
                    </div>
                </form>

                <!-- Quick Test Credentials Hint -->
                <div class="mt-4 pt-3 border-top text-center text-muted small bg-light p-2 rounded-3">
                    <div class="fw-semibold text-slate-700 mb-1"><i class="bi bi-info-circle me-1"></i>Tài khoản dùng để test:</div>
                    <div>Admin: <code>admin</code> / <code>123456</code></div>
                    <div>Khách: <code>khach1</code> / <code>123456</code></div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />
