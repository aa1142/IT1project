package com.jyphotel;



// 화면용 등급/타입 변환

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
        return uiGrade.trim();
    }

    public static String toDbGrade(String uiGrade) {

        String g = normalizeUiGrade(uiGrade);
        if ("스위트".equals(g) || "스윗트".equals(g)) {
            return "스윗트";
        }
        if ("스탠다드".equals(g) || "Standard".equalsIgnoreCase(g)) {
            return "스탠다드";
        }
        if ("디럭스".equals(g) || "Deluxe".equalsIgnoreCase(g)) {
            return "디럭스";
        }

        return g;

    }

    /** UI 등급 → DB room_grade CHECK 값 ('스탠다드','디럭스','스윗트') */
    public static String[] getGradeSearchValues(String uiGrade) {
        String base = toDbGrade(uiGrade);
        if ("스탠다드".equals(base)) {
            return new String[] { "스탠다드" };
        }
        if ("디럭스".equals(base)) {
            return new String[] { "디럭스" };
        }
        if ("스윗트".equals(base)) {
            return new String[] { "스윗트" };
        }
        return new String[] { base };
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



    public static String toUiGrade(String dbGrade) {

        if (dbGrade == null) {

            return "";

        }

        if ("스윗트".equals(dbGrade.trim())) {

            return "스위트";

        }

        return dbGrade.trim();

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

    /** 타입별 최대 수용 인원 (싱글 1, 더블 2, 패밀리 5) */
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

    /** 화면용 수용 안내 (예: 최대 2인 1박) */
    public static String getCapacityLabel(int room_type) {
        return "최대 " + getMaxGuests(room_type) + "인 1박";
    }

    public static final int ROOM_TYPE_SINGLE = 1;

    /** 싱글룸 노출: 어린이 0명이고 성인 수 = 방 수일 때만 */
    public static boolean canShowSingleRoom(int boot_adult, int boot_child, int rooms) {
        return boot_child == 0 && boot_adult == rooms;
    }

}

