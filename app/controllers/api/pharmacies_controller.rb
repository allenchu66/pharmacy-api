class Api::PharmaciesController < ApplicationController
  include Response

  # GET /api/pharmacies
  def index
    pharmacies = Pharmacy.all
    render_success(pharmacies.as_json(methods: :opening_hours_text))
  end

  # GET /api/pharmacies/:id
  def show
    pharmacy = Pharmacy.find(params[:id])
    render_success(pharmacy.as_json(methods: :opening_hours_text))
  rescue ActiveRecord::RecordNotFound
    render_error("Pharmacy not found", :not_found)
  end

  # GET /api/pharmacies/search?keyword=Care
  def search
    keyword = params[:keyword]
    pharmacies = Pharmacy.where("name ILIKE ?", "%#{keyword}%")
    render_success(pharmacies.as_json(methods: :opening_hours_text))
  end

  # GET /api/pharmacies/open?day_of_week=1&time=09:00
  def open
    day_of_week = params[:day_of_week]
    time = params[:time]

    pharmacies = Pharmacy.joins(:pharmacy_opening_hours)

    if time.present?
      pharmacies = pharmacies.where(
        "(pharmacy_opening_hours.day_of_week = :day AND pharmacy_opening_hours.open_time <= :time AND pharmacy_opening_hours.close_time >= :time) OR
         (pharmacy_opening_hours.day_of_week = :yesterday AND pharmacy_opening_hours.overnight = true AND pharmacy_opening_hours.close_time >= :time)",
        day: day_of_week,
        yesterday: (day_of_week.to_i - 1) % 7,
        time: time
      )
    else
      pharmacies = pharmacies.where(pharmacy_opening_hours: { day_of_week: day_of_week })
    end

    pharmacies = pharmacies.distinct

    render_success(pharmacies.as_json(methods: :opening_hours_text))
  end
end
