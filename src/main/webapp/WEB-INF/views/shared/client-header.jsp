<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : "Hệ Thống Cho Thuê Phòng Trọ Hiện Đại"}</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb;
            --primary-hover: #1d4ed8;
            --bg-body: #f8fafc;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: var(--bg-body);
            color: #334155;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .navbar-custom {
            background-color: #ffffff;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            padding: 0.85rem 0;
        }
        .navbar-brand {
            font-weight: 700;
            color: #0f172a;
            font-size: 1.25rem;
        }
        .nav-link {
            font-weight: 500;
            color: #475569;
            padding: 0.5rem 1rem !important;
            transition: color 0.2s ease;
        }
        .nav-link:hover, .nav-link.active {
            color: var(--primary) !important;
        }
        .room-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 0.85rem;
            overflow: hidden;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .room-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.08);
        }
        .room-img {
            height: 200px;
            width: 100%;
            object-fit: cover;
        }
        .badge-amenity {
            background-color: #f1f5f9;
            color: #475569;
            font-size: 0.75rem;
            padding: 0.35rem 0.65rem;
            border-radius: 6px;
            font-weight: 500;
        }
        .footer-client {
            background-color: #0f172a;
            color: #94a3b8;
            margin-top: auto;
            padding: 2.5rem 0 1.5rem 0;
        }
    </style>
</head>
<body>

<!-- Navbar for Guest & Customer -->
<nav class="navbar navbar-expand-lg navbar-custom sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/guest/rooms">
            <i class="bi bi-houses-fill text-primary me-2 fs-3"></i>
            <span>NhaTroSmart</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#clientNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="clientNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4">
                <li class="nav-item">
                    <a class="nav-link ${param.activeNav == 'rooms' ? 'active' : ''}" href="${pageContext.request.contextPath}/guest/rooms">
                        <i class="bi bi-grid me-1"></i>Danh sách phòng
                    </a>
                </li>
                <!-- Customer Only Menus (Shown when logged in) -->
                <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.role == 'CUSTOMER'}">
                    <li class="nav-item">
                        <a class="nav-link ${param.activeNav == 'contract' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/contract">
                            <i class="bi bi-file-earmark-check me-1"></i>Hợp đồng của tôi
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${param.activeNav == 'invoices' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/invoices">
                            <i class="bi bi-receipt me-1"></i>Hóa đơn tiền phòng
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${param.activeNav == 'tickets' ? 'active' : ''}" href="${pageContext.request.contextPath}/customer/tickets">
                            <i class="bi bi-tools me-1"></i>Báo hỏng sửa chữa
                        </a>
                    </li>
                </c:if>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        <div class="dropdown">
                            <button class="btn btn-light border d-flex align-items-center gap-2 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="bi bi-person-circle text-primary fs-5"></i>
                                <span class="fw-medium">${sessionScope.currentUser.fullName}</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser.role == 'ADMIN'}">
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2 me-2"></i>Trang Quản Trị</a></li>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/profile"><i class="bi bi-person-gear me-2"></i>Hồ sơ cá nhân</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/contract"><i class="bi bi-file-earmark-check me-2"></i>Hợp đồng của tôi</a></li>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile"><i class="bi bi-person-gear me-2"></i>Hồ sơ & Đổi mật khẩu</a></li>
                                    </c:otherwise>
                                </c:choose>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-primary px-3">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Đăng nhập
                        </a>
                        <a href="${pageContext.request.contextPath}/guest/register" class="btn btn-primary px-3">
                            <i class="bi bi-person-plus me-1"></i>Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>

<!-- Page Content Container Start -->
<div class="flex-grow-1">


