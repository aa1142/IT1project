package com.jyphotel;

public class BootVO {

    private String boot_no;
    private String room_grade;
    private int room_type;
    private int room_no;
    private int company_no;
    private String company_name;
    private String member_id;
    private String boot_phone;
    private String boot_name;
    private String boot_email;
    private String boot_checkin;
    private String boot_checkout;
    private int boot_adult;
    private int boot_child;
    private int boot_pay_check;
    private String boot_please;
    private int boot_confirm;
    private String reservation_code;

    public String getBoot_no() { return boot_no; }
    public void setBoot_no(String boot_no) { this.boot_no = boot_no; }

    public String getRoom_grade() { return room_grade; }
    public void setRoom_grade(String room_grade) { this.room_grade = room_grade; }

    public int getRoom_type() { return room_type; }
    public void setRoom_type(int room_type) { this.room_type = room_type; }

    public int getRoom_no() { return room_no; }
    public void setRoom_no(int room_no) { this.room_no = room_no; }

    public int getCompany_no() { return company_no; }
    public void setCompany_no(int company_no) { this.company_no = company_no; }

    public String getCompany_name() { return company_name; }
    public void setCompany_name(String company_name) { this.company_name = company_name; }

    public String getMember_id() { return member_id; }
    public void setMember_id(String member_id) { this.member_id = member_id; }

    public String getBoot_phone() { return boot_phone; }
    public void setBoot_phone(String boot_phone) { this.boot_phone = boot_phone; }

    public String getBoot_name() { return boot_name; }
    public void setBoot_name(String boot_name) { this.boot_name = boot_name; }

    public String getBoot_email() { return boot_email; }
    public void setBoot_email(String boot_email) { this.boot_email = boot_email; }

    public String getBoot_checkin() { return boot_checkin; }
    public void setBoot_checkin(String boot_checkin) { this.boot_checkin = boot_checkin; }

    public String getBoot_checkout() { return boot_checkout; }
    public void setBoot_checkout(String boot_checkout) { this.boot_checkout = boot_checkout; }

    public int getBoot_adult() { return boot_adult; }
    public void setBoot_adult(int boot_adult) { this.boot_adult = boot_adult; }

    public int getBoot_child() { return boot_child; }
    public void setBoot_child(int boot_child) { this.boot_child = boot_child; }

    public int getBoot_pay_check() { return boot_pay_check; }
    public void setBoot_pay_check(int boot_pay_check) { this.boot_pay_check = boot_pay_check; }

    public String getBoot_please() { return boot_please; }
    public void setBoot_please(String boot_please) { this.boot_please = boot_please; }

    public int getBoot_confirm() { return boot_confirm; }
    public void setBoot_confirm(int boot_confirm) { this.boot_confirm = boot_confirm; }

    public String getReservation_code() { return reservation_code; }
    public void setReservation_code(String reservation_code) { this.reservation_code = reservation_code; }

    public String getRoom_type_name() {
        return RoomTypeUtil.getDisplayName(room_grade, room_type);
    }

    public String getRoom_grade_ui() {
        return RoomTypeUtil.toUiGrade(room_grade);
    }
}
