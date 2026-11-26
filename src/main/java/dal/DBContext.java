package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Context for SQL Server connection using native JDBC.
 */
public class DBContext {
    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    private static final String SERVER_NAME = System.getenv("DB_SERVER") != null ? System.getenv("DB_SERVER") : "localhost";
    private static final String PORT_NUMBER = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "1433";
    private static final String DATABASE_NAME = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "QuanlyNhatro";
    private static final String USERNAME = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "sa";
    private static final String PASSWORD = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "123456";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC Driver not found!", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        // Set short login timeout so browser doesn't hang if SQL Server is not started
        DriverManager.setLoginTimeout(3);
        String url = String.format(
            "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=true;trustServerCertificate=true;loginTimeout=3;characterEncoding=UTF-8",
            SERVER_NAME, PORT_NUMBER, DATABASE_NAME
        );
        return DriverManager.getConnection(url, USERNAME, PASSWORD);
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to close database connection", e);
            }
        }
    }
}
