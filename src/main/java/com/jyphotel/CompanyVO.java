package com.jyphotel;

public class CompanyVO {

    private int company_no;
    private String company_name;
    private int room_type_count;
    private double rating;
    private String location;
    private String feature;
    private String meal_info;

    public int getCompany_no() { return company_no; }
    public void setCompany_no(int company_no) { this.company_no = company_no; }

    public String getCompany_name() { return company_name; }
    public void setCompany_name(String company_name) { this.company_name = company_name; }

    public int getRoom_type_count() { return room_type_count; }
    public void setRoom_type_count(int room_type_count) { this.room_type_count = room_type_count; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getFeature() { return feature; }
    public void setFeature(String feature) { this.feature = feature; }

    public String getMeal_info() { return meal_info; }
    public void setMeal_info(String meal_info) { this.meal_info = meal_info; }
}
