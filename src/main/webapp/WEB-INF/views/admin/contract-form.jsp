<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Ký Hợp Đồng Thuê Phòng" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="contracts" />
    <jsp:param name="pageTitle" value="Tạo Mới Hợp Đồng Thuê" />
</jsp:include>

<div class="row justify-content-center">
    <div class="col-12 col-lg-8">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <h5 class="fw-bold mb-0 text-slate-800">
                    <i class="bi bi-file-earmark-plus text-primary me-2"></i>
                    Thiết Lập Hợp Đồng Cho Thuê Phòng Mới
                </h5>
                <a href="${pageContext.request.contextPath}/admin/contracts" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                </a>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/contracts/create" method="post">
                <div class="row g-3 mb-3">
                    <!-- Chọn phòng trống -->
                    <div class="col-md-6">
                        <label for="roomId" class="form-label fw-semibold">Chọn phòng cho thuê <span class="text-danger">*</span></label>
                        <select class="form-select" id="roomId" name="roomId" required>
                            <option value="">-- Chọn phòng còn trống --</option>
                            <c:forEach items="${rooms}" var="r">
                                <option value="${r.roomId}">
                                    Phòng ${r.roomNumber} - Giá: <fmt:formatNumber value="${r.basePrice}" pattern="#,###" /> đ/tháng
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${empty rooms}">
                            <div class="form-text text-danger">Hiện không có phòng nào đang trống để tạo hợp đồng.</div>
                        </c:if>
                    </div>

                    <!-- Chọn người thuê -->
                    <div class="col-md-6">
                        <label for="userId" class="form-label fw-semibold">Khách thuê (Tài khoản) <span class="text-danger">*</span></label>
                        <select class="form-select" id="userId" name="userId" required>
                            <option value="">-- Chọn khách thuê đã đăng ký --</option>
                            <c:forEach items="${customers}" var="u">
                                <option value="${u.userId}">
                                    ${u.fullName} (SĐT: ${u.phone} - User: ${u.username})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="startDate" class="form-label fw-semibold">Ngày bắt đầu thuê <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="startDate" name="startDate" required>
                    </div>

                    <div class="col-md-6">
                        <label for="endDate" class="form-label fw-semibold">Ngày kết thúc hạn hợp đồng <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="endDate" name="endDate" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label for="depositAmount" class="form-label fw-semibold">Số tiền đặt cọc (VNĐ) <span class="text-danger">*</span></label>
                    <input type="number" step="50000" class="form-control" id="depositAmount" name="depositAmount" 
                           placeholder="Ví dụ: 3000000" required>
                    <div class="form-text">Tiền cọc này sẽ được lưu giữ và hoàn trả/cấn trừ khi thanh lý hợp đồng.</div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/admin/contracts" class="btn btn-light px-4">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary px-4 fw-medium" ${empty rooms ? 'disabled' : ''}>
                        <i class="bi bi-check2-circle me-1"></i> Xác nhận ký hợp đồng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Set default dates: startDate is today, endDate is 6 months later
    document.addEventListener("DOMContentLoaded", function () {
        const today = new Date().toISOString().split('T')[0];
        const sixMonthsLater = new Date();
        sixMonthsLater.setMonth(sixMonthsLater.getMonth() + 6);
        const endFormatted = sixMonthsLater.toISOString().split('T')[0];

        const startInput = document.getElementById('startDate');
        const endInput = document.getElementById('endDate');
        if (startInput && !startInput.value) startInput.value = today;
        if (endInput && !endInput.value) endInput.value = endFormatted;
    });
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


