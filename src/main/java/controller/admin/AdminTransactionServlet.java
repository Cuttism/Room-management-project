package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Transaction;
import service.AdminService;

import java.io.IOException;
import java.util.List;

/**
 * Controller for Admin Payment Transactions History (Lịch sử giao dịch thanh toán).
 */
@WebServlet(name = "AdminTransactionServlet", urlPatterns = {"/admin/transactions"})
public class AdminTransactionServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Transaction> transactions = adminService.getAllTransactions();
        req.setAttribute("transactions", transactions);
        req.getRequestDispatcher("/WEB-INF/views/admin/transaction-list.jsp").forward(req, resp);
    }
}
