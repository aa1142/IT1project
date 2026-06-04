package db;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;

public class DbContact {
	public static Connection getConnection() throws Exception {
        // 톰캣의 네이밍 시스템(JNDI)을 통해 XML 설정을 찾아옵니다.
        Context initContext = new InitialContext();
        Context envContext  = (Context)initContext.lookup("java:/comp/env");
        
        // context.xml에 적은 name="jdbc/oracle"을 매칭합니다.
        DataSource ds = (DataSource)envContext.lookup("jdbc/oracle");
        
        return ds.getConnection(); // 자동으로 연동된 커넥션 반환
    }
}
