package com.jyphotel;

// 화면용 등급/타입 변환 (UI: 한글 ↔ DB: STANDARD/DELUXE/SUITE)

public class RoomTypeUtil {

    public static boolean isAllGrade(String uiGrade) {
        if (uiGrade == null) {
            return true;
        }
        String g = uiGrade.trim();
        return g.isEmpty() || "전체".equals(g);
    }

    /** 화면 등급 기본값 — 전체/빈 값은 스탠다드 */
    public static String normalizeUiGrade(String uiGrade) {
        if (isAllGrade(uiGrade)) {
            return "스탠다드";
        }
        return toUiGrade(uiGrade);
    }

    /** UI 등급 → DB room_grade (STANDARD, DELUXE, SUITE) */
    public static String toDbGrade(String uiGrade) {
        if (uiGrade == null) {
            return "STANDARD";
        }
        String g = uiGrade.trim();
        if ("스위트".equals(g) || "스윗트".equals(g) || "SUITE".equalsIgnoreCase(g)) {
            return "SUITE";
        }
        if ("디럭스".equals(g) || "DELUXE".equalsIgnoreCase(g)) {
            return "DELUXE";
        }
        if ("스탠다드".equals(g) || "STANDARD".equalsIgnoreCase(g)) {
            return "STANDARD";
        }
        return g.toUpperCase();
    }

    /** DB 등급 → UI 한글 */
    public static String toUiGrade(String dbGrade) {
        if (dbGrade == null) {
            return "";
        }
        String g = dbGrade.trim();
        if ("SUITE".equals(g) || "스윗트".equals(g) || "스위트".equals(g)) {
            return "스위트";
        }
        if ("DELUXE".equals(g) || "디럭스".equals(g)) {
            return "디럭스";
        }
        if ("STANDARD".equals(g) || "스탠다드".equals(g)) {
            return "스탠다드";
        }
        return dbGrade.trim();
    }

    public static String[] getGradeSearchValues(String uiGrade) {
        String db = toDbGrade(uiGrade);
        if ("STANDARD".equals(db)) {
            return new String[] { "STANDARD", "스탠다드" };
        }
        if ("DELUXE".equals(db)) {
            return new String[] { "DELUXE", "디럭스" };
        }
        if ("SUITE".equals(db)) {
            return new String[] { "SUITE", "스윗트", "스위트" };
        }
        return new String[] { db };
    }

    public static String buildGradeInSql(String uiGrade, java.util.List<String> gradeParams) {
        String[] grades = getGradeSearchValues(uiGrade);
        if (grades.length == 0) {
            return "";
        }
        StringBuilder sb = new StringBuilder(" AND TRIM(r.room_grade) IN (");
        for (int i = 0; i < grades.length; i++) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append("?");
            gradeParams.add(grades[i]);
        }
        sb.append(") ");
        return sb.toString();
    }

    public static String getDisplayName(String room_grade, int room_type) {
        return getRoomTypeName(room_type);
    }

    public static String getRoomTypeName(int room_type) {
        if (room_type == 1) {
            return "싱글";
        }
        if (room_type == 2) {
            return "트윈";
        }
        if (room_type == 5) {
            return "패밀리";
        }
        return "객실";
    }

    public static int getMaxGuests(int room_type) {
        if (room_type == 1) {
            return 1;
        }
        if (room_type == 2) {
            return 2;
        }
        if (room_type == 5) {
            return 5;
        }
        return 1;
    }

    public static String getCapacityLabel(int room_type) {
        return "최대 " + getMaxGuests(room_type) + "인 1박";
    }

    public static final int ROOM_TYPE_SINGLE = 1;

    /** 싱글룸 노출: 어린이 0명이고 성인 1명일 때만 */
    public static boolean canShowSingleRoom(int boot_adult, int boot_child) {
        return boot_child == 0 && boot_adult == 1;
    }
}
