<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    </main>
    <!-- Footer -->
    <footer class="bg-white border-top py-3 px-4 text-center text-muted small mt-auto">
        <span>© 2026 Hệ Thống Quản Lý Nhà Trọ Thông Minh - Thiết kế chuẩn Java Web Servlet / JSP</span>
    </footer>
</div> <!-- #page-content-wrapper End -->
</div> <!-- #wrapper End -->

<!-- Bootstrap 5 Bundle JS with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Responsive sidebar toggle for mobile
    const toggleBtn = document.getElementById('menu-toggle');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            const sidebar = document.getElementById('sidebar-wrapper');
            sidebar.classList.toggle('d-none');
        });
    }
</script>
</body>
</html>
