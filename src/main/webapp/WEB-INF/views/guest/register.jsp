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
                        <label for="email" class="form-label fw-semibold">Địa chỉ Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email" value="<c:out value='${enteredEmail}'/>" placeholder="Ví dụ: nguyenvana@gmail.com" required>
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
                </form>

                <!-- Divider -->
                <div class="d-flex align-items-center my-3">
                    <hr class="flex-grow-1 text-muted">
                    <span class="px-2 small text-muted">Hoặc đăng ký nhanh bằng</span>
                    <hr class="flex-grow-1 text-muted">
                </div>

                <!-- Google Sign-Up / Sign-In Button -->
                <form id="googleRegisterForm" action="${pageContext.request.contextPath}/login/google" method="post" class="d-none">
                    <input type="hidden" name="credential" id="googleRegCredentialInput">
                </form>
                <div class="d-flex justify-content-center mb-3">
                    <div id="g_id_onload"
                         data-client_id="265168256933-o1bdbborcthrks671vocs159brnb8h1v.apps.googleusercontent.com"
                         data-context="signup"
                         data-ux_mode="popup"
                         data-callback="handleGoogleRegResponse"
                         data-auto_prompt="false">
                    </div>
                    <div class="g_id_signin"
                         data-type="standard"
                         data-shape="rectangular"
                         data-theme="outline"
                         data-text="signup_with"
                         data-size="large"
                         data-logo_alignment="left"
                         data-width="340">
                    </div>
                </div>

                <div class="text-center small text-muted">
                    Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" class="text-primary fw-semibold text-decoration-none">Đăng nhập tại đây</a>
                </div>

                <script src="https://accounts.google.com/gsi/client" async defer></script>
                <script>
                    function handleGoogleRegResponse(response) {
                        if (response && response.credential) {
                            document.getElementById("googleRegCredentialInput").value = response.credential;
                            document.getElementById("googleRegisterForm").submit();
                        }
                    }
                </script>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


