<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Đăng Ký Tài Khoản Khách Thuê" />
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-7 col-lg-5">
            <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                <div class="text-center mb-4">
                    <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-person-plus-fill fs-2"></i>
                    </div>
                    <h4 class="fw-bold text-slate-800">Đăng Ký Tài Khoản</h4>
                    <p class="text-muted small">Tạo tài khoản để theo dõi hợp đồng, hóa đơn và gửi phiếu bảo trì</p>
                </div>

                <!-- Error Alert -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/guest/register" method="post">
                    <div class="mb-3">
                        <label for="fullName" class="form-label fw-semibold">Họ và tên đầy đủ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName" value="<c:out value='${enteredFullName}'/>" placeholder="Ví dụ: Nguyễn Văn A" required>
                    </div>

                    <div class="mb-3">
                        <label for="phone" class="form-label fw-semibold">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="phone" name="phone" value="<c:out value='${enteredPhone}'/>" placeholder="Ví dụ: 0912345678" required>
                    </div>

                    <div class="mb-3">
                        <label for="username" class="form-label fw-semibold">Tên đăng nhập (Username) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="username" name="username" value="<c:out value='${enteredUsername}'/>" placeholder="Nhập tên tài khoản" required>
                    </div>

                    <div class="mb-3">
                        <label for="password" class="form-label fw-semibold">Mật khẩu <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="password" name="password" minlength="6" placeholder="Tối thiểu 6 ký tự" required>
                    </div>

                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label fw-semibold">Xác nhận mật khẩu <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" minlength="6" placeholder="Nhập lại mật khẩu" required>
                    </div>

                    <div class="d-grid mb-3">
                        <button type="submit" class="btn btn-primary btn-lg fw-bold">
                            <i class="bi bi-check2-circle me-1"></i> Hoàn tất đăng ký
                        </button>
                    </div>

                    <div class="text-center small text-muted">
                        Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" class="text-primary fw-semibold text-decoration-none">Đăng nhập tại đây</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


