<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    // 💡 サーブレットから送信されたセッション情報とrequestデータを受け取り、変数に格納します。
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");
    String address = (String) request.getAttribute("address");
    String grade = (String) request.getAttribute("grade");
    Integer count = (Integer) request.getAttribute("count");
    
    if(count == null) count = 0;

    // 💡 サーブレットから渡された予約履歴のリストオブジェクトを取り出します。
    List<Map<String, String>> reserveList = (List<Map<String, String>>) request.getAttribute("reserveList");
%>
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8" />
<title>マイページ | JYP HOTEL</title>
<style>
  @import url("https://googleapis.com");
  :root { --main: #111111; --point: #c8a96b; --bg: #f8f6f2; --text: #222222; --line: #e6dfd3; }
  * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Noto Sans JP", sans-serif; }
  body { background-color: var(--bg); color: var(--text); }
  header { display: flex; justify-content: space-between; align-items: center; padding: 15px 40px; background: #333; }
  .logo { font-size: 1.5rem; font-weight: 900; color: white; text-decoration: none; }
  .logo span { color: var(--point); }
  nav ul { display: flex; list-style: none; gap: 20px; }
  nav ul li a { text-decoration: none; color:#f5f5f5; font-weight: 700; font-size: 14px; }
  .mypage-container { max-width: 1000px; margin: 50px auto; display: flex; gap: 30px; padding: 0 20px; }
  .sidebar { width: 250px; background: white; border: 1px solid var(--line); padding: 30px 20px; border-radius: 12px; height: fit-content; }
  .welcome-box { text-align: center; padding-bottom: 25px; border-bottom: 1px solid var(--line); margin-bottom: 25px; }
  .menu-list { list-style: none; }
  .menu-list li a { text-decoration: none; color: #555; font-size: 15px; font-weight: 700; display: block; padding: 10px 15px; border-radius: 6px; }
  .menu-list li a.active, .menu-list li a:hover { background: var(--main); color: var(--point); }
  .content-area { flex: 1; background: white; border: 1px solid var(--line); padding: 40px; border-radius: 12px; }
  .section-title { font-size: 22px; font-weight: 900; color: var(--main); margin-bottom: 25px; border-bottom: 2px solid var(--main); padding-bottom: 10px; }
  
  /* 既存の会員情報テーブルスタイル */
  .info-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
  .info-table th { width: 150px; text-align: left; padding: 15px; background: #fafafa; border-bottom: 1px solid var(--line); }
  .info-table td { padding: 15px; border-bottom: 1px solid var(--line); }
  
  /* 💡 [新規追加した客室予約履歴テーブル用のプレミアムデザイン宣言] */
  .reserve-table { width: 100%; border-collapse: collapse; text-align: center; margin-top: 15px; font-size: 14px; }
  .reserve-table th { background: var(--main); color: white; padding: 12px; font-weight: 700; border: 1px solid #333; }
  .reserve-table td { padding: 14px 12px; border-bottom: 1px solid var(--line); color: #444; }
  .reserve-table tr:hover { background: #fafafa; }
  .no-data { padding: 40px !important; color: #999; font-style: italic; }
  
  /* 状態バッジのデザイン */
  .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
  .badge-success { background: #e6f4ea; color: #137333; } /* 予約完了 */
  .badge-cancel { background: #fce8e6; color: #c5221f; }  /* 予約キャンセル */
  
  footer { background: #333; color: #ccc; padding: 30px 20px; text-align: center; font-size: 13px; }
</style>
</head>
<body>
  <header>
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="logo">JYP <span>HOTEL</span></a>
    <nav>
      <ul>
        <li><a href="<%= request.getContextPath() %>/wls/index.jsp">メインへ</a></li>
        <li><a href="<%= request.getContextPath() %>/logoutAction">ログアウト</a></li>
      </ul>
    </nav>
  </header>
  <div class="mypage-container">
    <aside class="sidebar">
      <div class="welcome-box">
        <h3><%= sessionUserName %> 様</h3>
       <p>会員ランク: <span style="color:var(--point); font-weight:bold;"><%= "일반".equals(grade) ? "一般" : grade %></span></p>
      </div>
      <ul class="menu-list">
        <li><a href="<%= request.getContextPath() %>/myPage" class="active">会員情報の管理</a></li>
        <li><a href="<%= request.getContextPath() %>/memberModifyAction">会員情報の変更</a></li>
        <li><a href="<%= request.getContextPath() %>/changePasswordAction">パスワード変更</a></li>
        <li><a href="#" onclick="deleteAccount()" style="color:#d93025;">退会手続き</a></li>
      </ul>
    </aside>
    <main class="content-area">
      <h2 class="section-title">会員情報の管理</h2>
      <table class="info-table">
        <tr><th>お名前</th><td><%= sessionUserName %></td></tr>
        <tr><th>メールアドレス</th><td><%= email %></td></tr>
        <tr><th>携帯電話番号</th><td><%= phone %></td></tr>
        <tr><th>ご住所</th><td><%= address %></td></tr>
        <tr><th>累計予約回数</th><td><%= count %>回</td></tr>
      </table>
      
    
      <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; border-bottom: 2px solid var(--main); padding-bottom: 10px;">
        <h2 style="font-size: 22px; font-weight: 900; color: var(--main); margin: 0; border: none; padding: 0;">最近の宿泊予約履歴</h2>
        
        <!-- 🔗 누르면 다른 팀원이 만든 reviewWrite.jsp 전체 리스트 또는 작성 페이지로 즉시 화면 전환 -->
        <a href="<%= request.getContextPath() %>/review/reviewList.jsp" class="title-review-btn">クチコミを書く</a>
      </div>
      
      <table class="reserve-table">
        <thead>
          <tr>
            <th>予約番号</th>
            <th>ご利用客室名</th>
            <th>チェックイン日</th>
            <th>チェックアウト日</th>
            <th>予約状態</th>
          </tr>
        </thead>
        <tbody>
        <% if (reserveList == null || reserveList.isEmpty()) { %>
        
          <tr><td colspan="5" class="no-data">宿泊予約履歴がありません。</td></tr>
        <% } else { 
             for (Map<String, String> reserve : reserveList) { 
               String status = reserve.get("status");
               if (status == null) status = "予約完了";
               
               // 状態に応じて適切なバッジを付与するための翻訳マッピング
               String displayStatus = status;
               if ("예약완료".equals(status)) displayStatus = "予約完了";
               else if ("예약취소".equals(status) || "취소".equals(status)) displayStatus = "キャンセル";
               
               String badgeClass = "キャンセル".equals(displayStatus) || displayStatus.contains("取消") || displayStatus.contains("キャンセル") ? "badge-cancel" : "badge-success";
        %>
          <tr>
            <td><%= reserve.get("no") %></td>
            <td style="font-weight:700; color:var(--main);"><%= reserve.get("room") %></td>
            <td><%= reserve.get("in") %></td>
            <td><%= reserve.get("out") %></td>
            <td><span class="badge <%= badgeClass %>"><%= displayStatus %></span></td>
          </tr>
        <%    } 
           } %>
        </tbody>
      </table>
    </main>
  </div>
  <footer><p>&copy; 2026 JYP HOTEL. All rights reserved.</p></footer>

<script>
function deleteAccount() {
  if (confirm("本当にJYP HOTELを退会しますか？\n退会すると、すべての予約履歴と会員情報が削除され、復元することはできません。")) {
      location.href = "<%= request.getContextPath() %>/deleteAccountAction";
  }
}
</script>
</body>
</html>