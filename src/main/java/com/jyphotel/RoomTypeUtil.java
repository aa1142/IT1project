package com.jyphotel;



// 화면용 등급/타입 변환

public class RoomTypeUtil {



    public static String toDbGrade(String uiGrade) {

        if (uiGrade == null) {

            return "스탠다드";

        }

        if ("스위트".equals(uiGrade.trim())) {

            return "스윗트";

        }

        return uiGrade.trim();

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

            return "더블";

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

