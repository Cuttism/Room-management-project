<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="pageTitle" value="${isEdit ? 'Chỉnh Sửa Phòng' : 'Thêm Phòng Mới'}" />
</jsp:include>
<jsp:include page="/WEB-INF/views/shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="rooms" />
    <jsp:param name="pageTitle" value="${isEdit ? 'Chỉnh Sửa Thông Tin Phòng' : 'Tạo Mới Phòng Trọ'}" />
</jsp:include>

<style>
    .library-img-card {
        cursor: pointer;
        border: 2px solid #e2e8f0;
        border-radius: 0.65rem;
        overflow: hidden;
        transition: all 0.2s ease;
        background: #fff;
    }
    .library-img-card:hover {
        border-color: #93c5fd;
        transform: translateY(-2px);
    }
    .library-img-card.selected {
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.2);
    }
    .library-img-card .check-badge {
        display: none;
    }
    .library-img-card.selected .check-badge {
        display: inline-flex;
    }
    .preview-thumb-card {
        width: 120px;
        border: 1px solid #e2e8f0;
        border-radius: 0.5rem;
        overflow: hidden;
        background: #fff;
    }
</style>

<div class="row justify-content-center">
    <div class="col-12 col-lg-9">
        <div class="card-custom p-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom">
                <h5 class="fw-bold mb-0 text-slate-800">
                    <i class="bi ${isEdit ? 'bi-pencil-square text-warning' : 'bi-plus-circle text-primary'} me-2"></i>
                    ${isEdit ? "Cập nhật phòng " : "Thêm phòng trọ mới"}
                    <c:if test="${isEdit}"><span class="text-primary">${room.roomNumber}</span></c:if>
                </h5>
                <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary btn-sm">
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

            <form action="${pageContext.request.contextPath}${isEdit ? '/admin/rooms/edit' : '/admin/rooms/create'}" 
                  method="post" enctype="multipart/form-data" id="roomForm">
                <c:if test="${isEdit}">
                    <input type="hidden" name="roomId" value="${room.roomId}" />
                </c:if>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="roomNumber" class="form-label fw-semibold">Số phòng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="roomNumber" name="roomNumber" 
                               value="${isEdit ? room.roomNumber : ''}" placeholder="Ví dụ: P101, P202" required>
                    </div>

                    <div class="col-md-6">
                        <label for="basePrice" class="form-label fw-semibold">Giá thuê cơ bản (VNĐ / Tháng) <span class="text-danger">*</span></label>
                        <input type="number" step="10000" class="form-control" id="basePrice" name="basePrice" 
                               value="${isEdit ? room.basePrice : '3000000'}" required>
                    </div>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="maxOccupants" class="form-label fw-semibold">Số người ở tối đa</label>
                        <input type="number" min="1" max="10" class="form-control" id="maxOccupants" name="maxOccupants" 
                               value="${isEdit ? room.maxOccupants : 2}">
                    </div>

                    <div class="col-md-6">
                        <label for="status" class="form-label fw-semibold">Trạng thái phòng</label>
                        <select class="form-select" id="status" name="status">
                            <option value="AVAILABLE" ${room.status == 'AVAILABLE' ? 'selected' : ''}>Còn trống (AVAILABLE)</option>
                            <option value="OCCUPIED" ${room.status == 'OCCUPIED' ? 'selected' : ''}>Đang có khách thuê (OCCUPIED)</option>
                            <option value="MAINTENANCE" ${room.status == 'MAINTENANCE' ? 'selected' : ''}>Đang sửa chữa (MAINTENANCE)</option>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="amenities" class="form-label fw-semibold">Tiện ích đi kèm (Tags)</label>
                    <input type="text" class="form-control" id="amenities" name="amenities" 
                           value="${isEdit ? room.amenities : 'Máy lạnh, Gác lửng, Nóng lạnh, Tủ lạnh, Wifi tốc độ cao'}" 
                           placeholder="Cách nhau bởi dấu phẩy">
                    <div class="form-text">Ví dụ: Máy lạnh, Bình nóng lạnh, Gác lửng, Ban công thoáng mát</div>
                </div>

                <div class="mb-4">
                    <label for="description" class="form-label fw-semibold">Mô tả chi tiết phòng trọ</label>
                    <textarea class="form-control" id="description" name="description" rows="3" 
                              placeholder="Mô tả về diện tích, nội thất, hướng phòng, giờ giấc tự do...">${isEdit ? room.description : ''}</textarea>
                </div>

                <!-- Image Management & Preview Images Picker Section -->
                <div class="p-3 bg-light rounded-3 border mb-4">
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2 pb-3 mb-3 border-bottom">
                        <div>
                            <h6 class="fw-bold mb-1 text-slate-800">
                                <i class="bi bi-images me-1 text-primary"></i> Hình Ảnh Phòng Trọ & Thư Viện Ảnh Có Sẵn
                            </h6>
                            <span class="small text-muted">Tải ảnh mới từ máy tính hoặc chọn nhanh ảnh xem trước từ kho ảnh có sẵn trong cơ sở dữ liệu</span>
                        </div>
                        <button type="button" class="btn btn-outline-primary btn-sm fw-semibold d-inline-flex align-items-center gap-1"
                                data-bs-toggle="modal" data-bs-target="#imageLibraryModal">
                            <i class="bi bi-collection"></i>
                            <span>Thêm ảnh xem trước từ Database</span>
                        </button>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-7">
                            <label for="images" class="form-label small fw-semibold">Tải tệp ảnh mới từ máy tính</label>
                            <input class="form-control form-control-sm" type="file" id="images" name="images" multiple accept="image/*">
                        </div>
                        <div class="col-md-5">
                            <label for="imageRegion" class="form-label small fw-semibold">Phân vùng / Khu vực của ảnh</label>
                            <select class="form-select form-select-sm" id="imageRegion" name="imageRegion">
                                <option value="Khu A - Tầng 1">Khu A - Tầng 1</option>
                                <option value="Khu A - Tầng 2">Khu A - Tầng 2</option>
                                <option value="Khu B - Tầng 3">Khu B - Tầng 3</option>
                                <option value="Khu Studio Cao Cấp">Khu Studio Cao Cấp</option>
                            </select>
                        </div>
                    </div>

                    <!-- Hidden inputs container for selected existing database images -->
                    <div id="selectedLibraryInputs"></div>

                    <!-- Preview Container for Newly Selected Images (from Database Library + Local Upload) -->
                    <div id="previewGalleryWrapper" class="d-none mt-3 pt-3 border-top">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small fw-semibold text-primary">
                                <i class="bi bi-eye me-1"></i>Ảnh xem trước sẽ được thêm vào phòng:
                            </span>
                            <button type="button" class="btn btn-link btn-sm text-danger text-decoration-none p-0" id="clearPreviewBtn">
                                Xóa danh sách chọn
                            </button>
                        </div>
                        <div class="d-flex flex-wrap gap-2" id="previewGalleryList"></div>
                    </div>

                    <!-- Existing Images on Room (when editing) -->
                    <c:if test="${isEdit && not empty room.images}">
                        <div class="mt-3 pt-3 border-top">
                            <label class="form-label small fw-semibold text-slate-700 d-block mb-2">
                                Ảnh hiện có của phòng (Tích chọn ảnh nếu muốn xóa khi lưu):
                            </label>
                            <div class="d-flex flex-wrap gap-3">
                                <c:forEach items="${room.images}" var="img">
                                    <div class="preview-thumb-card shadow-sm p-1">
                                        <img src="${pageContext.request.contextPath}/${img.imageUrl}" 
                                             class="rounded w-100 object-fit-cover" 
                                             style="height: 75px;" alt="Room image">
                                        <div class="px-1 pt-1">
                                            <span class="badge bg-light text-secondary border w-100 text-truncate" style="font-size: 0.68rem;">
                                                ${not empty img.region ? img.region : 'Khu A - Tầng 1'}
                                            </span>
                                            <div class="form-check mt-1 mb-0">
                                                <input class="form-check-input" type="checkbox" name="deleteImageIds" value="${img.imageId}" id="delImg_${img.imageId}">
                                                <label class="form-check-label small text-danger" style="font-size: 0.75rem;" for="delImg_${img.imageId}">
                                                    Xóa ảnh
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-light px-4">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary px-4 fw-medium">
                        <i class="bi bi-save me-1"></i> ${isEdit ? "Cập nhật dữ liệu" : "Lưu phòng trọ"}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Choose Preview Images from Database Library with Filter by Newly Added & Sort/Filter by Region -->
<div class="modal fade" id="imageLibraryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-bottom">
                <div>
                    <h5 class="modal-title fw-bold text-slate-800">
                        <i class="bi bi-collection text-primary me-2"></i>Kho Ảnh Phòng Trọ Trong Cơ Sở Dữ Liệu
                    </h5>
                    <small class="text-muted">Chọn một hoặc nhiều ảnh có sẵn để gắn vào phòng trọ</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body p-4">
                <!-- Filter & Sort Controls Bar -->
                <div class="row g-2 mb-4 bg-light p-3 rounded-3 border">
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold mb-1">
                            <i class="bi bi-clock-history me-1 text-primary"></i>Lọc thời gian thêm
                        </label>
                        <select class="form-select form-select-sm" id="filterRecency">
                            <option value="ALL">Tất cả ảnh trong Database</option>
                            <option value="NEW_24H">Mới thêm gần đây (24 giờ qua)</option>
                            <option value="NEW_7D">Mới thêm trong 7 ngày qua</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label small fw-semibold mb-1">
                            <i class="bi bi-geo-alt me-1 text-primary"></i>Lọc theo Khu vực (Region)
                        </label>
                        <select class="form-select form-select-sm" id="filterRegion">
                            <option value="ALL">-- Tất cả khu vực --</option>
                            <option value="Khu A - Tầng 1">Khu A - Tầng 1</option>
                            <option value="Khu A - Tầng 2">Khu A - Tầng 2</option>
                            <option value="Khu B - Tầng 3">Khu B - Tầng 3</option>
                            <option value="Khu Studio Cao Cấp">Khu Studio Cao Cấp</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label small fw-semibold mb-1">
                            <i class="bi bi-sort-alpha-down me-1 text-primary"></i>Sắp xếp hiển thị
                        </label>
                        <select class="form-select form-select-sm" id="sortOrder">
                            <option value="NEWEST">Mới thêm gần nhất trước</option>
                            <option value="REGION_ASC">Theo Khu vực (A - Z)</option>
                            <option value="REGION_DESC">Theo Khu vực (Z - A)</option>
                            <option value="OLDEST">Cũ nhất trước</option>
                        </select>
                    </div>
                </div>

                <!-- Grid of Existing Database Images -->
                <div class="row g-3" id="libraryGrid">
                    <c:forEach items="${libraryImages}" var="libImg">
                        <div class="col-6 col-md-4 col-lg-3 library-item"
                             data-url="${libImg.imageUrl}"
                             data-region="${not empty libImg.region ? libImg.region : 'Khu A - Tầng 1'}"
                             data-timestamp="${libImg.createdDate != null ? libImg.createdDate.time : 0}">
                            <div class="library-img-card h-100 position-relative" onclick="toggleLibraryCard(this)">
                                <span class="check-badge position-absolute top-0 end-0 m-2 badge bg-primary rounded-circle p-2 shadow">
                                    <i class="bi bi-check-lg"></i>
                                </span>
                                <img src="${pageContext.request.contextPath}/${libImg.imageUrl}"
                                     class="w-100 object-fit-cover"
                                     style="height: 115px;"
                                     alt="Library image">
                                <div class="p-2">
                                    <div class="badge bg-primary-subtle text-primary border border-primary-subtle w-100 text-truncate mb-1">
                                        <i class="bi bi-geo-alt-fill me-1"></i>${not empty libImg.region ? libImg.region : 'Khu A - Tầng 1'}
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center small text-muted" style="font-size: 0.72rem;">
                                        <span>${not empty libImg.roomNumber ? 'P.'.concat(libImg.roomNumber) : 'Kho chung'}</span>
                                        <span>
                                            <c:if test="${libImg.createdDate != null}">
                                                <fmt:formatDate value="${libImg.createdDate}" pattern="dd/MM HH:mm" />
                                            </c:if>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div id="emptyLibraryNotice" class="text-center py-4 text-muted d-none">
                    <i class="bi bi-images fs-2 d-block mb-2"></i>
                    Không tìm thấy hình ảnh nào khớp với bộ lọc hiện tại.
                </div>
            </div>

            <div class="modal-footer border-top d-flex justify-content-between align-items-center">
                <span class="small text-muted" id="selectedCountLabel">Đã chọn: <strong>0</strong> ảnh</span>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary fw-semibold" id="applyLibrarySelectionBtn" data-bs-dismiss="modal">
                        <i class="bi bi-check2-circle me-1"></i> Áp dụng ảnh đã chọn
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
    const selectedUrls = new Map(); // url -> region

    function toggleLibraryCard(cardEl) {
        const itemEl = cardEl.closest(".library-item");
        const url = itemEl.getAttribute("data-url");
        const region = itemEl.getAttribute("data-region");

        if (cardEl.classList.contains("selected")) {
            cardEl.classList.remove("selected");
            selectedUrls.delete(url);
        } else {
            cardEl.classList.add("selected");
            selectedUrls.set(url, region);
        }
        document.getElementById("selectedCountLabel").innerHTML =
            "Đã chọn: <strong>" + selectedUrls.size + "</strong> ảnh";
    }

    document.addEventListener("DOMContentLoaded", function () {
        const filterRecency = document.getElementById("filterRecency");
        const filterRegion = document.getElementById("filterRegion");
        const sortOrder = document.getElementById("sortOrder");
        const libraryGrid = document.getElementById("libraryGrid");
        const emptyNotice = document.getElementById("emptyLibraryNotice");
        const applyBtn = document.getElementById("applyLibrarySelectionBtn");
        const clearBtn = document.getElementById("clearPreviewBtn");
        const fileInput = document.getElementById("images");

        function applyFilterAndSort() {
            const recencyVal = filterRecency.value;
            const regionVal = filterRegion.value;
            const sortVal = sortOrder.value;
            const nowMs = Date.now();
            const items = Array.from(libraryGrid.querySelectorAll(".library-item"));

            let visibleCount = 0;
            items.forEach(item => {
                const itemRegion = item.getAttribute("data-region") || "";
                const itemTs = parseInt(item.getAttribute("data-timestamp")) || 0;
                const ageHours = (nowMs - itemTs) / (1000 * 60 * 60);

                let matchRecency = true;
                if (recencyVal === "NEW_24H") {
                    matchRecency = ageHours <= 24;
                } else if (recencyVal === "NEW_7D") {
                    matchRecency = ageHours <= (24 * 7);
                }

                let matchRegion = (regionVal === "ALL" || itemRegion === regionVal);

                if (matchRecency && matchRegion) {
                    item.classList.remove("d-none");
                    visibleCount++;
                } else {
                    item.classList.add("d-none");
                }
            });

            items.sort((a, b) => {
                const regA = a.getAttribute("data-region") || "";
                const regB = b.getAttribute("data-region") || "";
                const tsA = parseInt(a.getAttribute("data-timestamp")) || 0;
                const tsB = parseInt(b.getAttribute("data-timestamp")) || 0;

                if (sortVal === "REGION_ASC") {
                    return regA.localeCompare(regB, 'vi');
                } else if (sortVal === "REGION_DESC") {
                    return regB.localeCompare(regA, 'vi');
                } else if (sortVal === "OLDEST") {
                    return tsA - tsB;
                }
                return tsB - tsA; // NEWEST default
            });

            items.forEach(item => libraryGrid.appendChild(item));
            emptyNotice.classList.toggle("d-none", visibleCount > 0);
        }

        filterRecency.addEventListener("change", applyFilterAndSort);
        filterRegion.addEventListener("change", applyFilterAndSort);
        sortOrder.addEventListener("change", applyFilterAndSort);

        function renderPreviewGallery() {
            const wrapper = document.getElementById("previewGalleryWrapper");
            const list = document.getElementById("previewGalleryList");
            const inputsContainer = document.getElementById("selectedLibraryInputs");

            list.innerHTML = "";
            inputsContainer.innerHTML = "";

            let totalPreviewCount = 0;

            // 1. Render selected library images
            selectedUrls.forEach((region, url) => {
                totalPreviewCount++;
                const hiddenInput = document.createElement("input");
                hiddenInput.type = "hidden";
                hiddenInput.name = "selectedLibraryImages";
                hiddenInput.value = url;
                inputsContainer.appendChild(hiddenInput);

                const card = document.createElement("div");
                card.className = "preview-thumb-card shadow-sm p-1";
                card.innerHTML =
                    '<img src="' + contextPath + '/' + url + '" class="rounded w-100 object-fit-cover" style="height: 75px;" alt="Preview">' +
                    '<div class="px-1 pt-1">' +
                        '<span class="badge bg-primary-subtle text-primary border border-primary-subtle w-100 text-truncate" style="font-size: 0.68rem;">' + region + '</span>' +
                        '<div class="small text-muted text-center mt-1" style="font-size: 0.68rem;">Từ Database</div>' +
                    '</div>';
                list.appendChild(card);
            });

            // 2. Render local file upload previews
            if (fileInput.files && fileInput.files.length > 0) {
                const chosenRegion = document.getElementById("imageRegion").value;
                Array.from(fileInput.files).forEach(file => {
                    totalPreviewCount++;
                    const objUrl = URL.createObjectURL(file);
                    const card = document.createElement("div");
                    card.className = "preview-thumb-card shadow-sm p-1";
                    card.innerHTML =
                        '<img src="' + objUrl + '" class="rounded w-100 object-fit-cover" style="height: 75px;" alt="Upload preview">' +
                        '<div class="px-1 pt-1">' +
                            '<span class="badge bg-success-subtle text-success border border-success-subtle w-100 text-truncate" style="font-size: 0.68rem;">' + chosenRegion + '</span>' +
                            '<div class="small text-muted text-truncate text-center mt-1" style="font-size: 0.68rem;">' + file.name + '</div>' +
                        '</div>';
                    list.appendChild(card);
                });
            }

            wrapper.classList.toggle("d-none", totalPreviewCount === 0);
        }

        applyBtn.addEventListener("click", renderPreviewGallery);
        fileInput.addEventListener("change", renderPreviewGallery);
        document.getElementById("imageRegion").addEventListener("change", renderPreviewGallery);

        clearBtn.addEventListener("click", function () {
            selectedUrls.clear();
            document.querySelectorAll(".library-img-card.selected").forEach(el => el.classList.remove("selected"));
            document.getElementById("selectedCountLabel").innerHTML = "Đã chọn: <strong>0</strong> ảnh";
            fileInput.value = "";
            renderPreviewGallery();
        });
    });
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp" />
