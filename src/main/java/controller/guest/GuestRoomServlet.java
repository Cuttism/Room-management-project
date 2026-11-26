package controller.guest;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import dal.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Room;
import model.RoomImage;

/**
 * Controller for Guest module: View available rooms, search, and view room detail.
 */
@WebServlet(name = "GuestRoomServlet", urlPatterns = {"/guest/rooms", "/guest/rooms/*", "/guest/rooms/search"})
public class GuestRoomServlet extends HttpServlet {
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String servletPath = req.getServletPath();

        // Check if viewing room detail: /guest/rooms/{id}
        if (pathInfo != null && pathInfo.length() > 1 && !pathInfo.equals("/search")) {
            try {
                int roomId = Integer.parseInt(pathInfo.substring(1));
                Room room = roomDAO.getRoomById(roomId);
                if (room != null) {
                    List<RoomImage> images = roomDAO.getImagesByRoomId(roomId);
                    req.setAttribute("room", room);
                    req.setAttribute("images", images);
                    req.getRequestDispatcher("/WEB-INF/views/guest/room-detail.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
            resp.sendRedirect(req.getContextPath() + "/guest/rooms");
            return;
        }

        // View list or search available rooms
        List<Room> availableRooms = roomDAO.getRoomsByStatus("AVAILABLE");

        // Filter if search parameters are present
        String keyword = req.getParameter("keyword");
        String maxPriceStr = req.getParameter("maxPrice");

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.toLowerCase().trim();
            availableRooms = availableRooms.stream()
                .filter(r -> (r.getAmenities() != null && r.getAmenities().toLowerCase().contains(kw))
                          || (r.getDescription() != null && r.getDescription().toLowerCase().contains(kw))
                          || r.getRoomNumber().toLowerCase().contains(kw))
                .collect(Collectors.toList());
        }

        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                BigDecimal maxPrice = new BigDecimal(maxPriceStr.trim());
                availableRooms = availableRooms.stream()
                    .filter(r -> r.getBasePrice() != null && r.getBasePrice().compareTo(maxPrice) <= 0)
                    .collect(Collectors.toList());
            } catch (Exception ignored) {
            }
        }

        req.setAttribute("rooms", availableRooms);
        req.getRequestDispatcher("/WEB-INF/views/guest/room-list.jsp").forward(req, resp);
    }
}
