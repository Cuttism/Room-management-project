package controller.auth;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

/**
 * Security filter enforcing authentication and role-based access control for /admin/* and /customer/* routes.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/admin", "/admin/*", "/customer/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !currentUser.isActive()) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=auth_required");
            return;
        }

        String servletPath = req.getServletPath();
        String role = currentUser.getRole() != null ? currentUser.getRole().toUpperCase() : "";

        // Admin routes require ADMIN role
        if (servletPath.startsWith("/admin") && !"ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=forbidden");
            return;
        }

        // Customer routes require CUSTOMER (or ADMIN) role
        if (servletPath.startsWith("/customer") && !"CUSTOMER".equals(role) && !"ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login?msg=forbidden");
            return;
        }

        chain.doFilter(request, response);
    }
}
