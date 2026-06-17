package com.jyphotel;

public class RoomVO {

    private int company_no;
    private String room_grade;
    private int room_type;
    private int room_price;
    private int remain_count;

    public int getCompany_no() { return company_no; }
    public void setCompany_no(int company_no) { this.company_no = company_no; }

    public String getRoom_grade() { return room_grade; }
    public void setRoom_grade(String room_grade) { this.room_grade = room_grade; }

    public int getRoom_type() { return room_type; }
    public void setRoom_type(int room_type) { this.room_type = room_type; }

    public int getRoom_price() { return room_price; }
    public void setRoom_price(int room_price) { this.room_price = room_price; }

    public int getRemain_count() { return remain_count; }
    public void setRemain_count(int remain_count) { this.remain_count = remain_count; }

    public String getRoom_type_name() {
        return RoomTypeUtil.getDisplayName(room_grade, room_type);
    }

    public String getRoom_grade_ui() {
        return RoomTypeUtil.toUiGrade(room_grade);
    }

    public String getCapacity_label() {
        return RoomTypeUtil.getCapacityLabel(room_type);
    }
}
