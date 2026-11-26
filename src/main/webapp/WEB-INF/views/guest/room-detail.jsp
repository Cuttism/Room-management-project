<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Chi Tiết Phòng ${room.roomNumber}" />
    <jsp:param name="activeNav" value="rooms" />
</jsp:include>

<div class="container py-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/guest/rooms" class="text-decoration-none">Danh sách phòng</a></li>
            <li class="breadcrumb-item active" aria-current="page">Phòng ${room.roomNumber}</li>
        </ol>
    </nav>

    <div class="row g-4">
        <!-- Cột trái: Gallery ảnh phòng -->
        <div class="col-12 col-lg-7">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-3">
                <c:choose>
                    <c:when test="${not empty images}">
                        <div id="roomCarousel" class="carousel slide" data-bs-ride="carousel">
                            <div class="carousel-inner">
                                <c:forEach items="${images}" var="img" varStatus="loop">
                                    <div class="carousel-item ${loop.first ? 'active' : ''}">
                                        <img src="${pageContext.request.contextPath}/${img.imageUrl}" class="d-block w-100 object-fit-cover" style="height: 420px;" alt="Ảnh phòng">
                                    </div>
                                </c:forEach>
                            </div>
                            <c:if test="${images.size() > 1}">
                                <button class="carousel-control-prev" type="button" data-bs-target="#roomCarousel" data-bs-slide="prev">
                                    <span class="carousel-control-prev-icon"></span>
                                </button>
                                <button class="carousel-control-next" type="button" data-bs-target="#roomCarousel" data-bs-slide="next">
                                    <span class="carousel-control-next-icon"></span>
                                </button>
                            </c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bg-light d-flex align-items-center justify-content-center text-muted" style="height: 420px;">
                            <i class="bi bi-image fs-1 me-2"></i> Chưa có hình ảnh hiển thị
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Thumbnail strip -->
            <c:if test="${images.size() > 1}">
                <div class="d-flex gap-2 overflow-auto pb-2">
                    <c:forEach items="${images}" var="img">
                        <img src="${pageContext.request.contextPath}/${img.imageUrl}" class="rounded border object-fit-cover shadow-sm" style="width: 80px; height: 60px;" alt="Thumb">
                    </c:forEach>
                </div>
            </c:if>

            <!-- Detailed Description -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mt-4">
                <h5 class="fw-bold mb-3 text-slate-800">Mô Tả Chi Tiết</h5>
                <p class="text-slate-600" style="white-space: pre-line; line-height: 1.7;">
                    ${not empty room.description ? room.description : "Phòng trọ cao cấp, thiết kế hiện đại, thoáng mát và sạch sẽ. Tự do giờ giấc, khóa cổng vân tay và camera an ninh 24/7."}
                </p>

                <h5 class="fw-bold mb-3 mt-3 text-slate-800">Tiện Ích & Nội Thất</h5>
                <div class="d-flex flex-wrap gap-2">
                    <c:forEach items="${room.amenities.split(',')}" var="amenity">
                        <span class="badge bg-light text-dark border px-3 py-2 fs-6">
                            <i class="bi bi-check-circle-fill text-success me-1"></i> ${amenity.trim()}
                        </span>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- Cột phải: Bảng giá, Chi phí dịch vụ & Form Liên hệ -->
        <div class="col-12 col-lg-5">
            <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 90px;">
                <span class="badge bg-success-subtle text-success border border-success-subtle align-self-start px-3 py-2 mb-2">
                    Đang trống - Sẵn sàng dọn vào
                </span>
                <h3 class="fw-bold text-slate-800 mb-1">Phòng ${room.roomNumber}</h3>
                <div class="text-primary fw-bold display-6 mb-3">
                    <fmt:formatNumber value="${room.basePrice}" pattern="#,###" /> <small class="fs-5 text-muted">đ/tháng</small>
                </div>

                <hr class="my-3">

                <h6 class="fw-bold mb-3 text-slate-700">Chi Phí Dịch Vụ Định Kỳ:</h6>
                <ul class="list-unstyled mb-4">
                    <li class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted"><i class="bi bi-lightning-charge me-2 text-warning"></i>Tiền điện:</span>
                        <strong>3.500 đ / kWh</strong>
                    </li>
                    <li class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted"><i class="bi bi-droplet me-2 text-info"></i>Tiền nước:</span>
                        <strong>25.000 đ / m³</strong>
                    </li>
                    <li class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted"><i class="bi bi-wifi me-2 text-primary"></i>Internet & Wifi:</span>
                        <strong>100.000 đ / phòng</strong>
                    </li>
                    <li class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted"><i class="bi bi-trash me-2 text-secondary"></i>Phí vệ sinh & rác:</span>
                        <strong>50.000 đ / phòng</strong>
                    </li>
                    <li class="d-flex justify-content-between py-2">
                        <span class="text-muted"><i class="bi bi-shield-check me-2 text-success"></i>Tiền đặt cọc:</span>
                        <strong class="text-success"><fmt:formatNumber value="${room.basePrice}" pattern="#,###" /> đ (1 tháng)</strong>
                    </li>
                </ul>

                <!-- Call To Action -->
                <div class="d-grid gap-2">
                    <a href="tel:0987654321" class="btn btn-primary btn-lg fw-bold">
                        <i class="bi bi-telephone-fill me-2"></i> Gọi hẹn xem phòng ngay
                    </a>
                    <c:choose>
                        <c:when test="${sessionScope.currentUser == null}">
                            <a href="${pageContext.request.contextPath}/guest/register" class="btn btn-outline-secondary">
                                <i class="bi bi-person-plus me-1"></i> Đăng ký tài khoản khách thuê
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="btn btn-outline-success" onclick="alert('Vui lòng liên hệ trực tiếp chủ trọ để hoàn tất thủ tục ký hợp đồng!');">
                                <i class="bi bi-check2-circle me-1"></i> Đã đăng nhập: Yêu cầu giữ phòng
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


