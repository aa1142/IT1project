package myNotice;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class NoticeDbUtil {
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
            throw new ExceptionInInitializerError("Oracle JDBC 드라이버(ojdbc8.jar)를 찾을 수 없습니다.");
        }
    }

    public static Connection getConnection() throws SQLException {
        SQLException lastError = null;

        for (String url : URLS) {
            try {
                Connection conn = DriverManager.getConnection(url, USER, PASS);
                System.out.println("[NoticeDB] connected: " + url);
                return conn;
            } catch (SQLException e) {
                lastError = e;
                System.err.println("[NoticeDB] connect failed: " + url + " -> " + e.getMessage());
            }
        }

        if (lastError != null) {
            throw lastError;
        }
        throw new SQLException("Oracle DB에 연결할 수 없습니다.");
    }
}
