<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%
    request.setCharacterEncoding("UTF-8");

    String bootNo = request.getParameter("bootNo");
    String bootPayCheck = request.getParameter("bootPayCheck");

    if (bootNo == null || bootPayCheck == null || bootNo.isEmpty()) {
%>
    <script>
        alert("決済通信パラメータが失われました。最初から再度お試しください。");
        location.href = "<%= request.getContextPath() %>/testex2/hotelsearch.jsp";
    </script>
<%
        return;
    }

    String cid = "TC0ONETIME"; 
    String partnerOrderId = bootNo;
    String partnerUserId = "JYP_HOTEL_GUEST";
    String itemName = "ホテル客室予約決済";
    String quantity = "1";
    String totalAmount = bootPayCheck;
    String taxFreeAmount = "0";

    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
    String approvalUrl = baseUrl + "/res/kakaoSuccess.jsp";
    String cancelUrl = baseUrl + "/res/kakaoCancel.jsp";
    String failUrl = baseUrl + "/res/kakaoFail.jsp";

    String nextRedirectUrl = "";
    String tid = "";

    try {
        URL url = new URL("https://open-api.kakaopay.com/online/v1/payment/ready");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "SECRET_KEY DEVC377EA1FE352A2FD439A893097F76D602E5D1");
        conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        conn.setDoOutput(true);

        String jsonPayload = "{"
            + "\"cid\":\"" + cid + "\","
            + "\"partner_order_id\":\"" + partnerOrderId + "\","
            + "\"partner_user_id\":\"" + partnerUserId + "\","
            + "\"item_name\":\"" + itemName + "\","
            + "\"quantity\":" + quantity + ","
            + "\"total_amount\":" + totalAmount + ","
            + "\"tax_free_amount\":" + taxFreeAmount + ","
            + "\"approval_url\":\"" + approvalUrl + "\","
            + "\"cancel_url\":\"" + cancelUrl + "\","
            + "\"fail_url\":\"" + failUrl + "\""
            + "}";

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonPayload.getBytes("UTF-8");
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        BufferedReader br;
        if (responseCode == 200) {
            br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
        } else {
            br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "UTF-8"));
        }

        StringBuilder responseBody = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            responseBody.append(line);
        }
        br.close();

        String result = responseBody.toString();
        System.out.println("[카카오 통신 로그] 응답결과: " + result);

        if (responseCode == 200) {
            int urlIdx = result.indexOf("next_redirect_pc_url\":\"") + "next_redirect_pc_url\":\"".length();
            nextRedirectUrl = result.substring(urlIdx, result.indexOf("\"", urlIdx));
            
            int tidIdx = result.indexOf("tid\":\"") + "tid\":\"".length();
            tid = result.substring(tidIdx, result.indexOf("\"", tidIdx));

            session.setAttribute("tid", tid);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    if (!nextRedirectUrl.isEmpty()) {
        response.sendRedirect(nextRedirectUrl);
        return;
    } else {
%>
    <script>
        alert("カカオ決済サーバーとの通信準備中に例外が発生しました。しばらくしてから再度お試しください。");
        history.go(-1);
    </script>
<%
    }
%>