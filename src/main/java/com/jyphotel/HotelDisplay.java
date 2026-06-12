package com.jyphotel;

// 지점별 화면 표시 정보 (DB에는 없고 JSP용)
public class HotelDisplay {

    public static void setCompanyInfo(CompanyVO c) {
        if (c == null) {
            return;
        }
        switch (c.getCompany_no()) {
            case 1:
                c.setRating(4.8);
                c.setLocation("도쿄역 도보 5분 · 긴자·丸の内 접근 편리");
                c.setFeature("도심 비즈니스·관광에 최적화된 프리미엄 호텔입니다.");
                c.setMeal_info("조식 뷔페 07:00~10:00 (별도 요금)");
                break;
            case 2:
                c.setRating(4.7);
                c.setLocation("신주쿠역 서쪽 출구 도보 3분");
                c.setFeature("쇼핑·야경·교통이 편리한 신주쿠 중심 호텔입니다.");
                c.setMeal_info("조식 뷔페 07:00~10:30");
                break;
            case 3:
                c.setRating(4.6);
                c.setLocation("요코하마역·미나토미라이 인근");
                c.setFeature("항구 도시의 여유로운 분위기와 넓은 객실을 제공합니다.");
                c.setMeal_info("조식 뷔페 07:00~10:00");
                break;
            default:
                c.setRating(4.5);
                c.setLocation("일본");
                c.setFeature("JYP HOTEL 지점");
                c.setMeal_info("조식 안내는 프론트 문의");
                break;
        }
    }
}
