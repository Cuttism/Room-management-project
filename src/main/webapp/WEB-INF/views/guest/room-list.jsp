<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/client-header.jsp">
    <jsp:param name="pageTitle" value="Danh Sách Phòng Trọ Còn Trống" />
    <jsp:param name="activeNav" value="rooms" />
</jsp:include>

<!-- Hero Banner & Search Section -->
<div class="bg-primary bg-gradient text-white py-5 mb-5">
    <div class="container text-center">
        <h1 class="fw-bold mb-3">Tìm Kiếm Phòng Trọ Tiện Nghi & Giá Tốt</h1>
        <p class="lead text-white-50 mb-4">Hệ thống phòng trọ sạch đẹp, an ninh 24/7, đầy đủ nội thất và giờ giấc tự do</p>
        
        <!-- Search & Filter Bar -->
        <div class="row justify-content-center">
            <div class="col-12 col-lg-8">
                <form action="${pageContext.request.contextPath}/guest/rooms/search" method="get" class="card p-3 shadow-lg border-0 text-dark">
                    <div class="row g-2 align-items-center">
                        <div class="col-md-5">
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control border-start-0" name="keyword" value="${param.keyword}" placeholder="Tiện ích (Máy lạnh, gác...)" />
                            </div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" name="maxPrice">
                                <option value="">-- Mức giá tối đa --</option>
                                <option value="2500000" ${param.maxPrice == '2500000' ? 'selected' : ''}>Dưới 2.5 triệu</option>
                                <option value="3500000" ${param.maxPrice == '3500000' ? 'selected' : ''}>Dưới 3.5 triệu</option>
                                <option value="5000000" ${param.maxPrice == '5000000' ? 'selected' : ''}>Dưới 5.0 triệu</option>
                            </select>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button type="submit" class="btn btn-primary fw-semibold">
                                <i class="bi bi-funnel me-1"></i> Tìm phòng
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Main Rooms Grid -->
<div class="container pb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-1 text-slate-800">Danh Sách Phòng Đang Trống</h4>
            <span class="text-muted small">Cập nhật theo thời gian thực</span>
        </div>
        <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 fs-6">
            ${rooms.size() != null ? rooms.size() : 0} phòng sẵn sàng
        </span>
    </div>

    <!-- Error/Notice Alert -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger mb-4" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
        </div>
    </c:if>

    <!-- Room Cards Grid -->
    <div class="row g-4">
        <c:forEach items="${rooms}" var="r">
            <div class="col-12 col-md-6 col-lg-4">
                <div class="room-card h-100 d-flex flex-column">
                    <!-- Image -->
                    <div class="position-relative">
                        <c:choose>
                            <c:when test="${not empty r.images}">
                                <img src="${pageContext.request.contextPath}/${r.images[0].imageUrl}" class="room-img" alt="Phòng ${r.roomNumber}">
                            </c:when>
                            <c:otherwise>
                                <div class="room-img bg-light d-flex align-items-center justify-content-center text-muted">
                                    <i class="bi bi-image fs-1"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <span class="position-absolute top-0 end-0 m-3 badge bg-success">Còn trống</span>
                    </div>

                    <!-- Content -->
                    <div class="p-4 d-flex flex-column flex-grow-1">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="fw-bold text-slate-800 mb-0">Phòng ${r.roomNumber}</h5>
                            <div class="text-primary fw-bold fs-5">
                                <fmt:formatNumber value="${r.basePrice}" pattern="#,###" /> <small class="fs-6 text-muted">đ/th</small>
                            </div>
                        </div>

                        <div class="small text-muted mb-3">
                            <i class="bi bi-people me-1"></i> Tối đa: <strong>${r.maxOccupants} người</strong>
                        </div>

                        <!-- Amenities snippet -->
                        <div class="d-flex flex-wrap gap-1 mb-3">
                            <c:forEach items="${r.amenities.split(',')}" var="amenity">
                                <span class="badge-amenity">${amenity.trim()}</span>
                            </c:forEach>
                        </div>

                        <p class="text-muted small text-truncate-2 mb-4 flex-grow-1">
                            ${not empty r.description ? r.description : "Phòng trọ thoáng mát, sạch sẽ, an ninh tốt..."}
                        </p>

                        <!-- Action Button -->
                        <a href="${pageContext.request.contextPath}/guest/rooms/${r.roomId}" class="btn btn-outline-primary w-100 fw-semibold mt-auto">
                            Xem chi tiết & Liên hệ <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty rooms}">
            <div class="col-12 text-center py-5">
                <i class="bi bi-door-closed fs-1 text-muted mb-3 d-block"></i>
                <h5 class="text-muted">Hiện tại không có phòng nào phù hợp với tìm kiếm của bạn.</h5>
                <a href="${pageContext.request.contextPath}/guest/rooms" class="btn btn-link">Xem tất cả phòng trống</a>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/client-footer.jsp" />


