<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="${isEdit ? 'Chỉnh Sửa Tài Khoản' : 'Thêm Tài Khoản Mới'}" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="customers" />
    <jsp:param name="pageTitle" value="${isEdit ? 'Cập Nhật Tài Khoản Người Dùng' : 'Tạo Tài Khoản Người Dùng Mới'}" />
</jsp:include>

<div class="row justify-content-center">
    <div class="col-12 col-lg-7">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <h5 class="fw-bold mb-0 text-slate-800">
                    <i class="bi ${isEdit ? 'bi-person-gear text-warning' : 'bi-person-plus text-primary'} me-2"></i>
                    ${isEdit ? 'Cập nhật tài khoản ' : 'Tạo tài khoản mới'}
                    <c:if test="${isEdit}"><span class="text-primary"><c:out value="${customer.email}" /></span></c:if>
                </h5>
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                </a>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}${isEdit ? '/admin/customers/edit' : '/admin/customers/create'}" method="post">
                <c:if test="${isEdit}">
                    <input type="hidden" name="userId" value="${customer.userId}" />
                </c:if>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="email" class="form-label fw-semibold">Địa chỉ Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email"
                               value="<c:out value='${isEdit ? customer.email : ""}'/>"
                               required placeholder="Ví dụ: khach3@gmail.com">
                    </div>

                    <div class="col-md-6">
                        <label for="password" class="form-label fw-semibold">
                            ${isEdit ? 'Mật khẩu mới (để trống nếu giữ nguyên)' : 'Mật khẩu khởi tạo *'}
                        </label>
                        <input type="password" class="form-control" id="password" name="password"
                               ${isEdit ? '' : 'required'} placeholder="Tối thiểu 6 ký tự">
                    </div>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="fullName" class="form-label fw-semibold">Họ và tên đầy đủ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName"
                               value="<c:out value='${isEdit ? customer.fullName : ""}'/>" required placeholder="Nguyễn Văn A">
                    </div>

                    <div class="col-md-6">
                        <label for="phone" class="form-label fw-semibold">Số điện thoại</label>
                        <input type="text" class="form-control" id="phone" name="phone"
                               value="<c:out value='${isEdit ? customer.phone : ""}'/>" placeholder="0912345678">
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label for="role" class="form-label fw-semibold">Vai trò hệ thống</label>
                        <select class="form-select" id="role" name="role">
                            <option value="CUSTOMER" ${!isEdit || customer.role == 'CUSTOMER' ? 'selected' : ''}>Khách thuê (CUSTOMER)</option>
                            <option value="ADMIN" ${isEdit && customer.role == 'ADMIN' ? 'selected' : ''}>Quản trị viên (ADMIN)</option>
                        </select>
                    </div>

                    <div class="col-md-6 d-flex align-items-end">
                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" role="switch" id="isActive" name="isActive"
                                   ${!isEdit || customer.active ? 'checked' : ''}>
                            <label class="form-check-label fw-semibold" for="isActive">Cho phép tài khoản hoạt động</label>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-light px-4">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary px-4 fw-medium">
                        <i class="bi bi-save me-1"></i> ${isEdit ? 'Lưu thay đổi' : 'Tạo tài khoản'}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
