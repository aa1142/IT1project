package myNotice;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class NoticeDbUtil {
    private static final String USER = "scott";
    private static final String PASS = "tiger";
    private static final String[] URLS = {
            "jdbc:oracle:thin:@localhost:1521:orcl"
    };

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("Oracle JDBCドライバー(ojdbc8.jar)が見つかりません。");
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
        throw new SQLException("Oracle DBに接続できません。");
    }
}
