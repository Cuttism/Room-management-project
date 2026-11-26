<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Hợp Đồng Thuê" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="contracts" />
    <jsp:param name="pageTitle" value="Danh Sách Hợp Đồng Thuê" />
</jsp:include>

<div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4">
    <div>
        <h5 class="fw-bold mb-1 text-slate-800">Quản Lý Hợp Đồng</h5>
        <span class="text-muted small">Theo dõi thời hạn thuê phòng, số tiền cọc và thanh lý hợp đồng</span>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/admin/contracts/create" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-file-earmark-plus"></i>
            <span>Tạo hợp đồng mới</span>
        </a>
    </div>
</div>

<c:if test="${param.msg == 'ContractCreated'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>Tạo hợp đồng cho thuê mới thành công! Phòng đã được chuyển sang trạng thái <strong>Đang thuê (OCCUPIED)</strong>.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<c:if test="${param.msg == 'TerminatedSuccessfully'}">
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        <i class="bi bi-info-circle me-2"></i>Đã thanh lý hợp đồng thành công! Tiền cọc đã được cấn trừ và phòng đã trở về trạng thái <strong>Còn trống (AVAILABLE)</strong>.
        <c:if test="${not empty sessionScope.lastSettlement and not empty sessionScope.settledContract}">
            <hr class="my-2">
            <div class="small">
                <strong>Kết quả quyết toán #HD-${sessionScope.settledContract.contractId} (Phòng P.${sessionScope.settledContract.room.roomNumber}):</strong>
                <ul class="mb-0 mt-1">
                    <li>Số ngày lưu trú trong tháng: <strong>${sessionScope.lastSettlement.occupiedDays} ngày</strong> &mdash; Tiền phòng: <strong><fmt:formatNumber value="${sessionScope.lastSettlement.proRatedRoomFee}" pattern="#,###" /> đ</strong></li>
                    <li>Tiền điện (${sessionScope.lastSettlement.usedElec} kWh): <strong><fmt:formatNumber value="${sessionScope.lastSettlement.elecFee}" pattern="#,###" /> đ</strong> | Tiền nước (${sessionScope.lastSettlement.usedWater} m³): <strong><fmt:formatNumber value="${sessionScope.lastSettlement.waterFee}" pattern="#,###" /> đ</strong> | Phí dịch vụ: <strong><fmt:formatNumber value="${sessionScope.lastSettlement.serviceFee}" pattern="#,###" /> đ</strong></li>
                    <li>Tổng chi phí kỳ cuối: <strong><fmt:formatNumber value="${sessionScope.lastSettlement.totalUsage}" pattern="#,###" /> đ</strong> | Tiền cọc đã thu: <strong><fmt:formatNumber value="${sessionScope.lastSettlement.deposit}" pattern="#,###" /> đ</strong></li>
                    <li>
                        <c:choose>
                            <c:when test="${sessionScope.lastSettlement.refundAmount >= 0}">
                                Số tiền hoàn trả lại cho khách: <strong class="text-success"><fmt:formatNumber value="${sessionScope.lastSettlement.refundAmount}" pattern="#,###" /> đ</strong>
                            </c:when>
                            <c:otherwise>
                                Số tiền khách cần đóng thêm: <strong class="text-danger"><fmt:formatNumber value="${-sessionScope.lastSettlement.refundAmount}" pattern="#,###" /> đ</strong>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </ul>
            </div>
        </c:if>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card-custom">
    <div class="table-responsive">
        <table class="table table-custom table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th>Mã HĐ</th>
                    <th>Phòng</th>
                    <th>Khách thuê</th>
                    <th>Số điện thoại</th>
                    <th>Ngày bắt đầu</th>
                    <th>Ngày kết thúc</th>
                    <th>Tiền cọc</th>
                    <th>Trạng thái</th>
                    <th class="text-end" style="width: 140px;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${contracts}" var="c">
                    <tr>
                        <td class="fw-semibold text-primary">#HD-${c.contractId}</td>
                        <td><span class="badge bg-light text-dark border px-2 py-1 fs-6">P.${c.room.roomNumber}</span></td>
                        <td class="fw-medium">${c.user.fullName}</td>
                        <td><i class="bi bi-telephone text-muted me-1"></i>${c.user.phone}</td>
                        <td>${c.startDate}</td>
                        <td>${c.endDate}</td>
                        <td class="fw-bold text-success">
                            <fmt:formatNumber value="${c.depositAmount}" pattern="#,###" /> đ
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${c.status == 'ACTIVE'}">
                                    <span class="badge bg-success bg-opacity-10 text-success badge-status">
                                        <i class="bi bi-circle-fill me-1" style="font-size: 0.5rem;"></i>Đang hiệu lực
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary bg-opacity-10 text-secondary badge-status">
                                        <i class="bi bi-dash-circle me-1"></i>Đã thanh lý
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <c:if test="${c.status == 'ACTIVE'}">
                                <a href="${pageContext.request.contextPath}/admin/contracts/terminate?id=${c.contractId}" 
                                   class="btn btn-sm btn-outline-danger d-inline-flex align-items-center gap-1"
                                   title="Thanh lý & Cấn trừ cọc">
                                    <i class="bi bi-box-arrow-right"></i>
                                    <span>Thanh lý</span>
                                </a>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty contracts}">
                    <tr>
                        <td colspan="9" class="text-center py-5 text-muted">
                            <i class="bi bi-file-earmark-x fs-1 d-block mb-2 text-secondary"></i>
                            Chưa có hợp đồng nào trong hệ thống.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />


