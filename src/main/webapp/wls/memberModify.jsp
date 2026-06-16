<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 💡 [バックエンド最適化]: Javaサーブレット(MemberModifyServlet)がOracle DBのデータを代わりに照会して渡します！
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('ログインが必要なサービスです。'); location.href='" + request.getContextPath() + "/wls/login.jsp';</script>");
        return;
    }

    // サーブレットがrequestオブジェクトに格納して送信したデータを安全に受け取ります。
    String nameKo = (String) request.getAttribute("name");
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");
    String address = (String) request.getAttribute("address");

    // 万が一、サーブレットを経由せずにアドレスバーに直接URLを入力してアクセスした場合に備えた防衛コード
    if (nameKo == null) {
        out.print("<script>location.href='" + request.getContextPath() + "/memberModifyAction';</script>");
        return;
    }
%>
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8" />
<title>会員情報変更 | JYP HOTEL</title>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<style>
  @import url("https://googleapis.com");
  :root { --main: #111111; --point: #c8a96b; --line: #e6dfd3; --bg: #f8f6f2; }
  * { margin:0; padding:0; box-sizing:border-box; font-family:"Noto Sans JP",sans-serif; }
  body { background: var(--bg); }
  header { height:80px; background:#333; display:flex; align-items:center; padding:0 40px; }
  .logo { font-size:28px; font-weight:900; color:white; text-decoration:none; }
  .logo span { color:var(--point); }
  .container { max-width:800px; margin:50px auto; background:white; border:1px solid #e6dfd3; padding:50px; border-radius:18px; }
  table { width:100%; border-collapse:collapse; margin-bottom:30px; }
  th { width:180px; text-align:left; padding:18px 14px; background:#fafafa; border-bottom:1px solid var(--line); }
  td { padding:16px 14px; border-bottom:1px solid var(--line); }
  input { height:46px; border:1px solid var(--line); border-radius:8px; padding:0 14px; width:100%; outline:none; }
  
  /* 💡 [アドレスバーのバグ解決のための重要CSS領域] */
  .inline { display:flex; gap:10px; align-items:center; }
  .inline input { flex: 1; min-width: 0; } /* ◀ 入力欄が残りの横幅を埋め、ボタンを押し出さないように防ぎます */
  
 
  .btn { 
    height:46px; 
    padding:0 16px; 
    background:var(--main); 
    color:#fff; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    white-space: nowrap; 
    font-size: 14px;
    font-weight: 500;
  }
  
  .submit-wrap { text-align:center; display:flex; justify-content:center; gap:15px; }
  .btn-submit { width:200px; height:50px; border:none; border-radius:10px; font-weight:700; cursor:pointer; }
  .btn-save { background: var(--main); color:white; }
  .btn-cancel { background: #ece7dd; }
</style>
</head>
<body>
<header><a href="<%= request.getContextPath() %>/wls/index.jsp" class="logo">JYP <span>HOTEL</span></a></header>
<div class="container">
  <h2>会員情報変更</h2>
  <form action="<%= request.getContextPath() %>/memberModifyAction" method="post" onsubmit="return validateForm()">
    <table>
      <tr><th>ユーザーID</th><td><input type="text" value="<%= sessionUserId %>" readonly style="background:#eee;"></td></tr>
      <tr><th>お名前</th><td><input type="text" name="name" value="<%= nameKo %>"></td></tr>
      <tr><th>メールアドレス</th><td><input type="text" name="email" value="<%= email %>"></td></tr>
      <tr><th>携帯電話番号</th><td><input type="text" name="phone" value="<%= phone %>"></td></tr>
      <tr><th>ご住所</th><td><div class="inline"><input type="text" id="address" name="address" value="<%= address %>" readonly><button type="button" class="btn" onclick="openAddressSearch()">住所検索</button></div></td></tr>
      <tr><th>パスワード確認</th><td><input type="password" name="password" id="password" placeholder="現在のパスワードを入力してください"></td></tr>
    </table>
    <div class="submit-wrap"><button type="submit" class="btn-submit btn-save">変更完了</button><button type="button" class="btn-submit btn-cancel" onclick="history.back()">キャンセル</button></div>
  </form>
</div>
<script>
function openAddressSearch() { new daum.Postcode({ oncomplete: function(data) { document.getElementById("address").value = data.address; } }).open(); }
function validateForm() {
  if(document.querySelector("input[name='name']").value.trim()==="") { alert("お名前を入力してください。"); return false; }
  if(document.getElementById("password").value.trim()==="") { alert("パスワードを入力してください。"); return false; }
  return true;
}
</script>
</body>
</html>