<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Cài Đặt Đơn Giá Dịch Vụ" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="settings" />
    <jsp:param name="pageTitle" value="Cài Đặt Đơn Giá Điện, Nước & Dịch Vụ" />
</jsp:include>

<div class="row justify-content-center">
    <div class="col-12 col-lg-7">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <div>
                    <h5 class="fw-bold mb-1 text-slate-800">
                        <i class="bi bi-sliders text-primary me-2"></i>
                        Bảng Đơn Giá Dịch Vụ Định Kỳ
                    </h5>
                    <span class="text-muted small">Đơn giá này được lưu trong cơ sở dữ liệu và áp dụng tự động khi chốt điện nước & thanh lý hợp đồng</span>
                </div>
            </div>

            <c:if test="${param.msg == 'Updated'}">
                <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>Đã cập nhật đơn giá dịch vụ vào cơ sở dữ liệu thành công!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/settings" method="post">
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="electricityPerKwh" class="form-label fw-semibold">
                            <i class="bi bi-lightning-charge text-warning me-1"></i>Đơn giá Điện (VNĐ / kWh) <span class="text-danger">*</span>
                        </label>
                        <input type="number" step="100" min="0" class="form-control" id="electricityPerKwh"
                               name="electricityPerKwh" value="${rates.electricityPerKwh}" required>
                    </div>

                    <div class="col-md-6">
                        <label for="waterPerM3" class="form-label fw-semibold">
                            <i class="bi bi-droplet text-info me-1"></i>Đơn giá Nước (VNĐ / m³) <span class="text-danger">*</span>
                        </label>
                        <input type="number" step="500" min="0" class="form-control" id="waterPerM3"
                               name="waterPerM3" value="${rates.waterPerM3}" required>
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label for="internetFee" class="form-label fw-semibold">
                            <i class="bi bi-wifi text-primary me-1"></i>Phí Internet / Wifi (VNĐ / tháng) <span class="text-danger">*</span>
                        </label>
                        <input type="number" step="1000" min="0" class="form-control" id="internetFee"
                               name="internetFee" value="${rates.internetFee}" required>
                    </div>

                    <div class="col-md-6">
                        <label for="trashFee" class="form-label fw-semibold">
                            <i class="bi bi-trash text-secondary me-1"></i>Phí Vệ sinh & Rác (VNĐ / tháng) <span class="text-danger">*</span>
                        </label>
                        <input type="number" step="1000" min="0" class="form-control" id="trashFee"
                               name="trashFee" value="${rates.trashFee}" required>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <button type="submit" class="btn btn-primary px-4 fw-medium">
                        <i class="bi bi-save me-1"></i> Lưu cài đặt đơn giá
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
