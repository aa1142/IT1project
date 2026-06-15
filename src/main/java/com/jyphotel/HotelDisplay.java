package com.jyphotel;

/**
 * 지점·객실 화면 표시 정보 (DB 없음, JSP용)
 * 이미지 경로는 아래에 하드코딩 — webapp/images/ 폴더에 파일을 두세요.
 */
public class HotelDisplay {

    public static void setCompanyInfo(CompanyVO c) {
        if (c == null) {
            return;
        }
        switch (c.getCompany_no()) {
            case 1:
                c.setLocation("도쿄역 도보 5분 · 긴자·丸の内 접근 편리");
                c.setFeature("도심 비즈니스·관광에 최적화된 프리미엄 호텔입니다.");
                c.setMeal_info("조식 뷔페 07:00~10:00 (별도 요금)");
                c.setCover_image("/images/tokyo.png");
                break;
            case 2:
                c.setLocation("신주쿠역 서쪽 출구 도보 3분");
                c.setFeature("쇼핑·야경·교통이 편리한 신주쿠 중심 호텔입니다.");
                c.setMeal_info("조식 뷔페 07:00~10:30");
                c.setCover_image("/images/shinjuku.png");
                break;
            case 3:
                c.setLocation("요코하마역·미나토미라이 인근");
                c.setFeature("항구 도시의 여유로운 분위기와 넓은 객실을 제공합니다.");
                c.setMeal_info("조식 뷔페 07:00~10:00");
                c.setCover_image("/images/yokohama.png");
                break;
            default:
                c.setLocation("일본");
                c.setFeature("JYP HOTEL 지점");
                c.setMeal_info("조식 안내는 프론트 문의");
                c.setCover_image(null);
                break;
        }
    }

    /** 호텔 갤러리 — 대표 1장 + 추가 3장 (썸네일 선택용) */
    public static String[] getHotelGalleryPaths(int companyNo) {
        switch (companyNo) {
            case 1:
                return img(
                        "/images/tokyomain.png",
                        "/images/hotel_tokyorobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            case 2:
                return img(
                        "/images/shinmain.png",
                        "/images/hotel_shinjukurobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            case 3:
                return img(
                        "/images/yokomain.png",
                        "/images/hotel_yokohamarobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            default:
                return new String[0];
        }
    }

    /** 객실 이미지 (등급·타입별, 모든 지점 공통) */
    public static String[] getRoomImagePaths(int companyNo, String roomGrade, int roomType) {
        String grade = RoomTypeUtil.toDbGrade(RoomTypeUtil.toUiGrade(roomGrade));
        String[] shared = getSharedRoomImages(grade, roomType);
        if (shared.length > 0) {
            return shared;
        }
        String cover = getCoverPath(companyNo);
        if (cover != null) {
            return img(cover);
        }
        return new String[0];
    }

    private static String[] getSharedRoomImages(String grade, int roomType) {
        if ("스탠다드".equals(grade) && roomType == 1) {
            return img("/images/rooms/standard_single.png", "/images/rooms/bathroom.png");
        }
        if ("스탠다드".equals(grade) && roomType == 2) {
            return img("/images/rooms/standard_twin.png", "/images/rooms/bathroom.png");
        }
        if ("스탠다드".equals(grade) && roomType == 5) {
            return img("/images/rooms/standard_family.png", "/images/rooms/bathroom.png");
        }
        if ("디럭스".equals(grade) && roomType == 1) {
            return img("/images/rooms/deluxe_single.png", "/images/rooms/bathroom.png");
        }
        if ("디럭스".equals(grade) && roomType == 2) {
            return img("/images/rooms/deluxe_twin.png", "/images/rooms/bathroom.png");
        }
        if ("디럭스".equals(grade) && roomType == 5) {
            return img("/images/rooms/deluxe_family.png", "/images/rooms/bathroom.png");
        }
        if ("스윗트".equals(grade) && roomType == 5) {
            return img("/images/rooms/suite_family.png", "/images/rooms/suite_bathroom.png");
        }
        if ("스윗트".equals(grade) && roomType == 1) {
            return img("/images/rooms/suite_family.png", "/images/rooms/suite_bathroom.png");
        }
        if ("스윗트".equals(grade) && roomType == 2) {
            return img("/images/rooms/suite_family.png", "/images/rooms/suite_bathroom.png");
        }
        return new String[0];
    }

    public static String toUrl(String contextPath, String webPath) {
        if (webPath == null || webPath.isEmpty()) {
            return "";
        }
        return contextPath + webPath;
    }

    private static String getCoverPath(int companyNo) {
        switch (companyNo) {
            case 1: return "/images/tokyo.png";
            case 2: return "/images/shinjuku.png";
            case 3: return "/images/yokohama.png";
            default: return null;
        }
    }

    private static String[] img(String... paths) {
        return paths;
    }
}
