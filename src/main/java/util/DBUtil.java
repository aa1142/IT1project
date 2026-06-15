package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String USER = "proid";
    private static final String PASS = "3431";
    private static final String[] URLS = {
            "jdbc:oracle:thin:@localhost:1521:xe",
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
    };

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("Oracle JDBC driver not found. Check WEB-INF/lib/ojdbc8.jar.");
        }
    }

    public static Connection getConnection() throws SQLException {
        SQLException lastError = null;

        for (String url : URLS) {
            try {
                return DriverManager.getConnection(url, USER, PASS);
            } catch (SQLException e) {
                lastError = e;
            }
        }

        throw lastError != null ? lastError : new SQLException("Could not connect to Oracle DB.");
    }

    public static void close(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception ignored) {
            }
        }
    }
}
