<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Tổng Quan Hệ Thống" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="dashboard" />
    <jsp:param name="pageTitle" value="Bảng Điều Khiển Quản Lý" />
</jsp:include>

<!-- Notification Alert -->
<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible fade show card-custom border-0 border-start border-success border-4 mb-4" role="alert">
        <i class="bi bi-check-circle-fill me-2 text-success"></i><strong>Thành công:</strong> Thao tác đã được ghi nhận trên hệ thống!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<!-- TẦNG 1: 4 THẺ KPI TỔNG QUAN -->
<div class="row g-4 mb-4">
    <!-- KPI 1: Doanh thu tháng này -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="card-custom p-4 border-start border-primary border-4">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <span class="text-muted small fw-medium text-uppercase">Doanh Thu T${currentMonth}/${currentYear}</span>
                    <h3 class="fw-bold text-slate-800 mb-0 mt-1">
                        <fmt:formatNumber value="${kpis.currentMonthRevenue}" pattern="#,###" /> <small class="fs-6 text-muted">đ</small>
                    </h3>
                </div>
                <div class="rounded-3 bg-primary bg-opacity-10 text-primary p-3">
                    <i class="bi bi-cash-stack fs-3"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- KPI 2: Số phòng trống -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="card-custom p-4 border-start border-success border-4">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <span class="text-muted small fw-medium text-uppercase">Phòng Trống</span>
                    <h3 class="fw-bold text-success mb-0 mt-1">
                        ${kpis.availableRoomsCount} <small class="fs-6 text-muted fw-normal">phòng</small>
                    </h3>
                </div>
                <div class="rounded-3 bg-success bg-opacity-10 text-success p-3">
                    <i class="bi bi-door-open fs-3"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- KPI 3: Tiền nợ chưa thu -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="card-custom p-4 border-start border-danger border-4">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <span class="text-muted small fw-medium text-uppercase">Nợ Chưa Thu</span>
                    <h3 class="fw-bold text-danger mb-0 mt-1">
                        <fmt:formatNumber value="${kpis.totalUnpaidAmount}" pattern="#,###" /> <small class="fs-6 text-muted">đ</small>
                    </h3>
                </div>
                <div class="rounded-3 bg-danger bg-opacity-10 text-danger p-3">
                    <i class="bi bi-exclamation-triangle fs-3"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- KPI 4: Phiếu báo hỏng cần xử lý -->
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="card-custom p-4 border-start border-warning border-4">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <span class="text-muted small fw-medium text-uppercase">Báo Hỏng Cần Sửa</span>
                    <h3 class="fw-bold text-warning mb-0 mt-1">
                        ${kpis.openTicketsCount} <small class="fs-6 text-muted fw-normal">phiếu</small>
                    </h3>
                </div>
                <div class="rounded-3 bg-warning bg-opacity-10 text-warning p-3">
                    <i class="bi bi-tools fs-3"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- TẦNG 2: BIỂU ĐỒ DOANH THU & DANH SÁCH NHẮC NHỞ (2:1) -->
<div class="row g-4 mb-4">
    <!-- Cột trái (2/3): Biểu đồ doanh thu 6 tháng -->
    <div class="col-12 col-lg-8">
        <div class="card-custom p-4 h-100">
            <div class="d-flex align-items-center justify-content-between mb-4">
                <div>
                    <h6 class="fw-bold mb-1 text-slate-800">Biểu Đồ Doanh Thu 6 Tháng Gần Nhất</h6>
                    <small class="text-muted">Tổng số tiền thực thu từ hóa đơn tiền phòng & dịch vụ</small>
                </div>
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">Thực thu</span>
            </div>
            <div style="height: 280px; position: relative;">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Cột phải (1/3): Thao tác nhanh & Trạng thái -->
    <div class="col-12 col-lg-4">
        <div class="card-custom p-4 h-100 d-flex flex-column justify-content-between">
            <div>
                <h6 class="fw-bold mb-3 text-slate-800">Tác Vụ Nhanh Quản Trị</h6>
                <div class="d-flex flex-column gap-2 mb-3">
                    <a href="${pageContext.request.contextPath}/admin/billing" class="btn btn-sm btn-primary py-2 px-3 fw-medium text-start d-flex align-items-center">
                        <i class="bi bi-lightning-charge-fill me-2 fs-6"></i>
                        <span>Chốt điện nước tháng ${currentMonth}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/rooms/create" class="btn btn-sm btn-outline-primary py-2 px-3 fw-medium text-start d-flex align-items-center">
                        <i class="bi bi-plus-circle me-2 fs-6"></i>
                        <span>Thêm phòng trọ mới</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/contracts/create" class="btn btn-sm btn-outline-success py-2 px-3 fw-medium text-start d-flex align-items-center">
                        <i class="bi bi-file-earmark-plus me-2 fs-6"></i>
                        <span>Ký hợp đồng cho thuê</span>
                    </a>
                </div>
            </div>

            <div class="border-top pt-3 mt-2">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="small text-muted">Tỉ lệ lấp đầy phòng:</span>
                    <span class="small fw-bold">${kpis.occupiedRoomsCount} / ${(kpis.occupiedRoomsCount + kpis.availableRoomsCount)} phòng</span>
                </div>
                <div class="progress" style="height: 8px;">
                    <c:set var="totalRooms" value="${kpis.occupiedRoomsCount + kpis.availableRoomsCount}" />
                    <c:set var="occupancyRate" value="${totalRooms > 0 ? (kpis.occupiedRoomsCount * 100 / totalRooms) : 0}" />
                    <div class="progress-bar bg-success" role="progressbar" style="width: ${occupancyRate}%"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- TẦNG 3: BẢNG HÓA ĐƠN GẦN ĐÂY -->
<div class="card-custom mb-4">
    <div class="card-header bg-white py-3 px-4 border-bottom d-flex align-items-center justify-content-between">
        <h6 class="fw-bold mb-0 text-slate-800">Hóa Đơn Thu Phí Gần Nhất</h6>
        <a href="${pageContext.request.contextPath}/admin/invoices" class="btn btn-sm btn-link text-decoration-none">Xem toàn bộ <i class="bi bi-arrow-right"></i></a>
    </div>
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>Mã HĐ</th>
                    <th>Phòng</th>
                    <th>Khách thuê</th>
                    <th>Kỳ thu</th>
                    <th>Điện (Số)</th>
                    <th>Nước (Số)</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${recentInvoices}" var="inv">
                    <tr>
                        <td class="fw-medium text-primary">#INV-${inv.invoiceId}</td>
                        <td><span class="badge bg-light text-dark border px-2 py-1">P.${inv.contract.room.roomNumber}</span></td>
                        <td>${inv.contract.user.fullName}</td>
                        <td>T${inv.billingMonth}/${inv.billingYear}</td>
                        <td>${inv.elecUsage} kWh</td>
                        <td>${inv.waterUsage} m³</td>
                        <td class="fw-bold text-slate-800"><fmt:formatNumber value="${inv.totalAmount}" pattern="#,###" /> đ</td>
                        <td>
                            <c:choose>
                                <c:when test="${inv.paymentStatus == 'PAID'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status"><i class="bi bi-check2 me-1"></i>Đã thanh toán</span>
                                </c:when>
                                <c:when test="${inv.paymentStatus == 'PENDING'}">
                                    <span class="badge bg-warning bg-opacity-10 text-warning badge-status"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger bg-opacity-10 text-danger badge-status"><i class="bi bi-clock-history me-1"></i>Chưa thanh toán</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty recentInvoices}">
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">Chưa có hóa đơn nào được tạo gần đây.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- Script vẽ biểu đồ Revenue Chart.js -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const ctx = document.getElementById('revenueChart').getContext('2d');
        
        // Mock / DB Data parsed from revenueStats
        const labels = ['T6/2026', 'T7/2026', 'T8/2026', 'T9/2026', 'T10/2026', 'T${currentMonth}/${currentYear}'];
        const dataValues = [15200000, 18500000, 17800000, 21000000, 22400000, ${kpis.currentMonthRevenue != null ? kpis.currentMonthRevenue : 0}];

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: dataValues,
                    backgroundColor: 'rgba(37, 99, 235, 0.85)',
                    borderRadius: 6,
                    maxBarThickness: 42
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.raw);
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return (value / 1000000).toFixed(0) + ' Tr';
                            }
                        },
                        grid: { borderDash: [4, 4], color: '#f1f5f9' }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
    });
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


