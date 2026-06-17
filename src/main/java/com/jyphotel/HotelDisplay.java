package com.jyphotel;

/**
 * 지점·객실 화면 표시 정보 (DB 없음, JSP용)
 * company_no 1=도쿄, 2=신주쿠, 3=요코하마 (지점명 우선 매핑)
 */
public class HotelDisplay {

    public static void setCompanyInfo(CompanyVO c) {
        if (c == null) {
            return;
        }
        switch (resolveBranchKey(c)) {
            case "tokyo":
                c.setLocation("東京駅徒歩5分 · 銀座・丸の内へのアクセス便利");
                c.setFeature("都心のビジネス・観光に最適なプレミアムホテルです。");
                c.setMeal_info("朝食ビュッフェ 07:00~10:00（別料金）");
                c.setCover_image("/images/tokyo.png");
                break;
            case "shinjuku":
                c.setLocation("新宿駅西口徒歩3分");
                c.setFeature("ショッピング・夜景・交通に便利な新宿中心のホテルです。");
                c.setMeal_info("朝食ビュッフェ 07:00~10:30");
                c.setCover_image("/images/shinjuku.png");
                break;
            case "yokohama":
                c.setLocation("横浜駅・みなとみらい近郊");
                c.setFeature("港町のゆったりした雰囲気と広い客室を提供します。");
                c.setMeal_info("朝食ビュッフェ 07:00~10:00");
                c.setCover_image("/images/yokohama.png");
                break;
            default:
                c.setLocation("日本");
                c.setFeature("JYP HOTEL 支店");
                c.setMeal_info("朝食のご案内はフロントへお問い合わせください");
                c.setCover_image("/images/yokohama.png");
                break;
        }
    }

    /** 호텔 갤러리 — 대표 1장 + 추가 3장 */
    public static String[] getHotelGalleryPaths(int companyNo, String companyName) {
        CompanyVO tmp = new CompanyVO();
        tmp.setCompany_no(companyNo);
        tmp.setCompany_name(companyName);
        switch (resolveBranchKey(tmp)) {
            case "tokyo":
                return img(
                        "/images/tokyomain.png",
                        "/images/hotel_tokyorobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            case "shinjuku":
                return img(
                        "/images/shinmain.png",
                        "/images/hotel_shinjukurobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            case "yokohama":
                return img(
                        "/images/yokomain.png",
                        "/images/hotel_yokohamarobi.png",
                        "/images/hotel_restorant.png",
                        "/images/hotel_gym.png");
            default:
                return img("/images/yokohama.png");
        }
    }

    public static String[] getHotelGalleryPaths(CompanyVO company) {
        if (company == null) {
            return new String[0];
        }
        return getHotelGalleryPaths(company.getCompany_no(), company.getCompany_name());
    }

    public static String[] getRoomImagePaths(int companyNo, String roomGrade, int roomType) {
        String grade = RoomTypeUtil.toDbGrade(RoomTypeUtil.toUiGrade(roomGrade));
        String[] shared = getSharedRoomImages(grade, roomType);
        if (shared.length > 0) {
            return shared;
        }
        CompanyVO tmp = new CompanyVO();
        tmp.setCompany_no(companyNo);
        String cover = getCoverPath(resolveBranchKey(tmp));
        if (cover != null) {
            return img(cover);
        }
        return new String[0];
    }

    private static String[] getSharedRoomImages(String grade, int roomType) {
        String db = RoomTypeUtil.toDbGrade(grade);
        if ("STANDARD".equals(db) && roomType == 1) {
            return img("/images/rooms/standard_single.png", "/images/rooms/bathroom.png");
        }
        if ("STANDARD".equals(db) && roomType == 2) {
            return img("/images/rooms/standard_twin.png", "/images/rooms/bathroom.png");
        }
        if ("STANDARD".equals(db) && roomType == 5) {
            return img("/images/rooms/standard_family.png", "/images/rooms/bathroom.png");
        }
        if ("DELUXE".equals(db) && roomType == 1) {
            return img("/images/rooms/deluxe_single.png", "/images/rooms/bathroom.png");
        }
        if ("DELUXE".equals(db) && roomType == 2) {
            return img("/images/rooms/deluxe_twin.png", "/images/rooms/bathroom.png");
        }
        if ("DELUXE".equals(db) && roomType == 5) {
            return img("/images/rooms/deluxe_family.png", "/images/rooms/bathroom.png");
        }
        if ("SUITE".equals(db)) {
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

    /** 지점명(東京/新宿/横浜) 우선, 없으면 company_no 로 판별 */
    static String resolveBranchKey(CompanyVO c) {
        if (c == null) {
            return "tokyo";
        }
        String name = c.getCompany_name();
        if (name != null) {
            if (name.contains("東京") || name.contains("도쿄")) {
                return "tokyo";
            }
            if (name.contains("新宿") || name.contains("신주쿠")) {
                return "shinjuku";
            }
            if (name.contains("横浜") || name.contains("요코하마")) {
                return "yokohama";
            }
        }
        int no = c.getCompany_no();
        if (no == 1) {
            return "tokyo";
        }
        if (no == 2) {
            return "shinjuku";
        }
        if (no == 3) {
            return "yokohama";
        }
        return "tokyo";
    }

    private static String getCoverPath(String branchKey) {
        if ("tokyo".equals(branchKey)) {
            return "/images/tokyo.png";
        }
        if ("shinjuku".equals(branchKey)) {
            return "/images/shinjuku.png";
        }
        if ("yokohama".equals(branchKey)) {
            return "/images/yokohama.png";
        }
        return null;
    }

    private static String[] img(String... paths) {
        return paths;
    }
}
