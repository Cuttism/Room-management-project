<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Sidebar Column -->
<aside id="sidebar-wrapper">
    <div class="sidebar-brand">
        <i class="bi bi-building-fill-gear text-primary me-2 fs-4"></i>
        <span>Room Master</span>
    </div>
    <ul class="sidebar-menu">
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard" 
               class="sidebar-link ${param.activeMenu == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-grid-1x2-fill"></i>
                <span>Tổng quan</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/rooms" 
               class="sidebar-link ${param.activeMenu == 'rooms' ? 'active' : ''}">
                <i class="bi bi-door-open-fill"></i>
                <span>Quản lý phòng</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/contracts" 
               class="sidebar-link ${param.activeMenu == 'contracts' ? 'active' : ''}">
                <i class="bi bi-file-earmark-text-fill"></i>
                <span>Hợp đồng thuê</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/customers" 
               class="sidebar-link ${param.activeMenu == 'customers' ? 'active' : ''}">
                <i class="bi bi-people-fill"></i>
                <span>Khách thuê & Tài khoản</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/billing" 
               class="sidebar-link ${param.activeMenu == 'billing' ? 'active' : ''}">
                <i class="bi bi-lightning-charge-fill"></i>
                <span>Chốt điện nước</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/invoices" 
               class="sidebar-link ${param.activeMenu == 'invoices' ? 'active' : ''}">
                <i class="bi bi-receipt-cutoff"></i>
                <span>Hóa đơn & Thu phí</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/transactions" 
               class="sidebar-link ${param.activeMenu == 'transactions' ? 'active' : ''}">
                <i class="bi bi-credit-card-2-front-fill"></i>
                <span>Lịch sử giao dịch</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/tickets" 
               class="sidebar-link ${param.activeMenu == 'tickets' ? 'active' : ''}">
                <i class="bi bi-tools"></i>
                <span>Báo hỏng & Sửa chữa</span>
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/settings" 
               class="sidebar-link ${param.activeMenu == 'settings' ? 'active' : ''}">
                <i class="bi bi-sliders"></i>
                <span>Cài đặt đơn giá</span>
            </a>
        </li>
        <li class="sidebar-item mt-4 pt-3 border-top border-secondary border-opacity-25">
            <a href="${pageContext.request.contextPath}/guest/rooms" class="sidebar-link text-info">
                <i class="bi bi-box-arrow-up-right"></i>
                <span>Xem trang Khách</span>
            </a>
        </li>
    </ul>
</aside>

<!-- Right Page Wrapper Start -->
<div id="page-content-wrapper">
    <!-- Top Navigation Header -->
    <header class="main-header d-flex align-items-center justify-content-between">
        <div class="d-flex align-items-center">
            <button class="btn btn-light d-md-none me-3" id="menu-toggle">
                <i class="bi bi-list fs-5"></i>
            </button>
            <h5 class="mb-0 fw-semibold text-slate-800">${param.pageTitle != null ? param.pageTitle : "Bảng điều khiển"}</h5>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="dropdown">
                <button class="btn btn-light border-0 d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center fw-bold" style="width: 34px; height: 34px; font-size: 0.85rem;">
                        AD
                    </div>
                    <span class="fw-medium small d-none d-sm-inline">
                        ${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : 'Chủ Trọ (Admin)'}
                    </span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/profile"><i class="bi bi-person me-2"></i>Hồ sơ cá nhân</a></li>
                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/settings"><i class="bi bi-gear me-2"></i>Cài đặt đơn giá</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </header>
    <!-- Main Content Body -->
    <main class="main-content">
