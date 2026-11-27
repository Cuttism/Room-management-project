package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Room;
import service.AdminService;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Controller for Admin Room Management (CRUD, multi-image upload, soft delete).
 */
@WebServlet(name = "AdminRoomServlet", urlPatterns = {"/admin/rooms", "/admin/rooms/create", "/admin/rooms/edit", "/admin/rooms/delete"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB per file
    maxRequestSize = 1024 * 1024 * 50    // 50MB total
)
public class AdminRoomServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();
    private static final String UPLOAD_DIR = "uploads/rooms";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        switch (servletPath) {
            case "/admin/rooms/create":
                req.setAttribute("isEdit", false);
                req.setAttribute("libraryImages", adminService.getLibraryImages());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                break;

            case "/admin/rooms/edit":
                int editId = parseId(req.getParameter("id"));
                Room room = adminService.getRoomById(editId);
                if (room == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?error=RoomNotFound");
                    return;
                }
                req.setAttribute("isEdit", true);
                req.setAttribute("room", room);
                req.setAttribute("libraryImages", adminService.getLibraryImages());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                break;

            case "/admin/rooms/delete":
                int delId = parseId(req.getParameter("id"));
                if (adminService.hasActiveContractByRoomId(delId)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?error=RoomOccupiedCannotDelete");
                    return;
                }
                adminService.softDeleteRoom(delId);
                resp.sendRedirect(req.getContextPath() + "/admin/rooms?msg=DeletedSuccessfully");
                break;

            case "/admin/rooms":
            default:
                List<Room> rooms = adminService.getAllRooms();
                req.setAttribute("rooms", rooms);
                req.getRequestDispatcher("/WEB-INF/views/admin/room-list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String servletPath = req.getServletPath();

        String roomNumber = req.getParameter("roomNumber");
        String basePriceStr = req.getParameter("basePrice");
        String status = req.getParameter("status");
        String maxOccupantsStr = req.getParameter("maxOccupants");
        String amenities = req.getParameter("amenities");
        String description = req.getParameter("description");
        String imageRegion = req.getParameter("imageRegion");
        if (imageRegion == null || imageRegion.trim().isEmpty()) {
            imageRegion = "Khu A - Tầng 1";
        }

        BigDecimal basePrice = (basePriceStr != null && !basePriceStr.isEmpty()) ? new BigDecimal(basePriceStr) : BigDecimal.ZERO;
        int maxOccupants = (maxOccupantsStr != null && !maxOccupantsStr.isEmpty()) ? Integer.parseInt(maxOccupantsStr) : 2;
        boolean isEditMode = "/admin/rooms/edit".equals(servletPath);
        int editRoomId = isEditMode ? parseId(req.getParameter("roomId")) : 0;

        if (basePrice.compareTo(BigDecimal.ZERO) <= 0) {
            req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Giá thuê phòng cơ bản phải lớn hơn 0 VNĐ!");
            req.setAttribute("isEdit", isEditMode);
            if (isEditMode) req.setAttribute("room", adminService.getRoomById(editRoomId));
            req.setAttribute("libraryImages", adminService.getLibraryImages());
            req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
            return;
        }

        if (maxOccupants < 1 || maxOccupants > 20) {
            req.setAttribute("errorMessage", "Ràng buộc dữ liệu: Số người ở tối đa phải từ 1 đến 20 người!");
            req.setAttribute("isEdit", isEditMode);
            if (isEditMode) req.setAttribute("room", adminService.getRoomById(editRoomId));
            req.setAttribute("libraryImages", adminService.getLibraryImages());
            req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
            return;
        }

        if (isEditMode && adminService.hasActiveContractByRoomId(editRoomId) && !"OCCUPIED".equalsIgnoreCase(status)) {
            req.setAttribute("errorMessage", "Ràng buộc nghiệp vụ: Phòng này đang có hợp đồng thuê hiệu lực (ACTIVE) nên không thể chuyển sang trạng thái '" + status + "'. Vui lòng thanh lý hợp đồng trước!");
            req.setAttribute("isEdit", true);
            req.setAttribute("room", adminService.getRoomById(editRoomId));
            req.setAttribute("libraryImages", adminService.getLibraryImages());
            req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
            return;
        }

        // 1. Process uploaded multi images from computer
        List<String> imageUrls = saveUploadedImages(req);

        // 2. Process existing images picked from Database Library Modal
        String[] selectedLibraryImages = req.getParameterValues("selectedLibraryImages");
        if (selectedLibraryImages != null) {
            for (String libUrl : selectedLibraryImages) {
                if (libUrl != null && !libUrl.trim().isEmpty() && !imageUrls.contains(libUrl.trim())) {
                    imageUrls.add(libUrl.trim());
                }
            }
        }

        if ("/admin/rooms/create".equals(servletPath)) {
            if (adminService.isRoomNumberExists(roomNumber, 0)) {
                req.setAttribute("errorMessage", "Số phòng '" + roomNumber + "' đã tồn tại trên hệ thống!");
                req.setAttribute("isEdit", false);
                req.setAttribute("libraryImages", adminService.getLibraryImages());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                return;
            }

            Room newRoom = new Room(0, roomNumber, basePrice, status, maxOccupants, amenities, description, true);
            adminService.createRoom(newRoom, imageUrls, imageRegion);
            resp.sendRedirect(req.getContextPath() + "/admin/rooms?msg=CreatedSuccessfully");

        } else if ("/admin/rooms/edit".equals(servletPath)) {
            int roomId = parseId(req.getParameter("roomId"));

            if (adminService.isRoomNumberExists(roomNumber, roomId)) {
                req.setAttribute("errorMessage", "Số phòng '" + roomNumber + "' đã thuộc về một phòng khác!");
                req.setAttribute("isEdit", true);
                req.setAttribute("room", adminService.getRoomById(roomId));
                req.setAttribute("libraryImages", adminService.getLibraryImages());
                req.getRequestDispatcher("/WEB-INF/views/admin/room-form.jsp").forward(req, resp);
                return;
            }

            // Optional deletion of checked existing images
            String[] deleteImageIds = req.getParameterValues("deleteImageIds");
            if (deleteImageIds != null) {
                for (String imgIdStr : deleteImageIds) {
                    int imgId = parseId(imgIdStr);
                    if (imgId > 0) {
                        adminService.deleteRoomImage(imgId);
                    }
                }
            }

            Room updatedRoom = new Room(roomId, roomNumber, basePrice, status, maxOccupants, amenities, description, true);
            adminService.updateRoom(updatedRoom, imageUrls, imageRegion);
            resp.sendRedirect(req.getContextPath() + "/admin/rooms?msg=UpdatedSuccessfully");
        }
    }

    private List<String> saveUploadedImages(HttpServletRequest req) {
        List<String> fileUrls = new ArrayList<>();
        try {
            String appPath = req.getServletContext().getRealPath("");
            String uploadPath = appPath + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            File sourceUploadDir = new File("C:/Users/ADMIN/Desktop/JAV102/Project-room-management/src/main/webapp/" + UPLOAD_DIR);
            if (!sourceUploadDir.exists()) sourceUploadDir.mkdirs();

            Collection<Part> parts = req.getParts();
            for (Part part : parts) {
                if ("images".equals(part.getName()) && part.getSize() > 0) {
                    String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    if (submittedFileName != null && !submittedFileName.isEmpty()) {
                        String uniqueFileName = System.currentTimeMillis() + "_" + submittedFileName;
                        File destFile = new File(uploadDir, uniqueFileName);
                        part.write(destFile.getAbsolutePath());

                        // Mirror to src/main/webapp/uploads/rooms so uploaded files persist across rebuilds
                        File srcFile = new File(sourceUploadDir, uniqueFileName);
                        if (!destFile.getCanonicalPath().equalsIgnoreCase(srcFile.getCanonicalPath())) {
                            java.nio.file.Files.copy(
                                destFile.toPath(),
                                srcFile.toPath(),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING
                            );
                        }
                        fileUrls.add(UPLOAD_DIR + "/" + uniqueFileName);
                    }
                }
            }
        } catch (Exception e) {
            // Log upload error
        }
        return fileUrls;
    }

    private int parseId(String val) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return 0;
        }
    }
}
