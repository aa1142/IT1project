package com.jyphotel;



import java.time.LocalDate;

import java.time.format.DateTimeFormatter;

import java.time.temporal.ChronoUnit;



// 날짜·요금 계산

public class HotelPriceUtil {



    public static final int BREAKFAST_UNIT = 40000;

    public static final int FAST_CHECKIN_UNIT = 30000;



    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");



    public static int toInt(String value, int defaultValue) {

        if (value == null || value.trim().isEmpty()) {

            return defaultValue;

        }

        try {

            return Integer.parseInt(value.trim());

        } catch (NumberFormatException e) {

            return defaultValue;

        }

    }



    public static int calcNights(String boot_checkin, String boot_checkout) {

        try {

            LocalDate in = LocalDate.parse(boot_checkin, FMT);

            LocalDate out = LocalDate.parse(boot_checkout, FMT);

            long days = ChronoUnit.DAYS.between(in, out);

            if (days < 1) {

                return 1;

            }

            return (int) days;

        } catch (Exception e) {

            return 1;

        }

    }



    public static String calcCheckout(String boot_checkin, int nights) {

        try {

            LocalDate in = LocalDate.parse(boot_checkin, FMT);

            return in.plusDays(nights).format(FMT);

        } catch (Exception e) {

            return boot_checkin;

        }

    }



    /** 숙박 인원 (성인+어린이, 최소 1) */

    public static int getGuestCount(int boot_adult, int boot_child) {

        int guests = boot_adult + boot_child;

        return guests < 1 ? 1 : guests;

    }



    /** 객실 요금 = 1박 단가 × 박수 × 방 수 × 인원 */

    public static int calcRoomTotal(int room_price, int nights, int rooms,

            int boot_adult, int boot_child) {

        return room_price * nights * rooms * getGuestCount(boot_adult, boot_child);

    }



    /** 조식 = 1인 1박 단가 × 인원 × 박수 */

    public static int calcBreakfastTotal(int boot_adult, int boot_child, int nights) {

        return BREAKFAST_UNIT * getGuestCount(boot_adult, boot_child) * nights;

    }



  /** 총 요금 (옵션 포함) */

    public static int calcGrandTotal(int room_price, int nights, int rooms,

            int boot_adult, int boot_child, boolean breakfast, boolean fastCheckin) {

        int total = calcRoomTotal(room_price, nights, rooms, boot_adult, boot_child);

        if (breakfast) {

            total += calcBreakfastTotal(boot_adult, boot_child, nights);

        }

        if (fastCheckin) {

            total += FAST_CHECKIN_UNIT;

        }

        return total;

    }



    /** boot_please 에서 금액 항목 추출 */

    public static int parsePleaseAmount(String boot_please, String key) {

        if (boot_please == null || key == null) {

            return 0;

        }

        String marker = key + ":";

        if (!boot_please.contains(marker)) {

            return 0;

        }

        try {

            String part = boot_please.substring(boot_please.indexOf(marker) + marker.length());

            int bar = part.indexOf('|');

            if (bar >= 0) {

                part = part.substring(0, bar);

            }

            return Integer.parseInt(part.trim());

        } catch (Exception e) {

            return 0;

        }

    }



    public static boolean parsePleaseFlag(String boot_please, String key) {

        if (boot_please == null || key == null) {

            return false;

        }

        String marker = key + ":";

        if (!boot_please.contains(marker)) {

            return false;

        }

        try {

            String part = boot_please.substring(boot_please.indexOf(marker) + marker.length());

            int bar = part.indexOf('|');

            if (bar >= 0) {

                part = part.substring(0, bar);

            }

            return "Y".equalsIgnoreCase(part.trim());

        } catch (Exception e) {

            return false;

        }

    }



    /** @deprecated calcRoomTotal 사용 */

    public static int calcTotal(int room_price, int nights, int rooms) {

        return room_price * nights * rooms;

    }

    /** boot / member 전화번호 — DB CHECK(010-0000-0000) 형식으로 변환 */
    public static String normalizeBootPhone(String phone) {
        if (phone == null) {
            return "";
        }
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() == 11 && digits.startsWith("010")) {
            return digits.substring(0, 3) + "-" + digits.substring(3, 7) + "-" + digits.substring(7);
        }
        return phone.trim();
    }

    public static boolean isValidBootPhone(String phone) {
        return phone != null && phone.matches("^010-[0-9]{4}-[0-9]{4}$");
    }

}

