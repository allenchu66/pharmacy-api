class Api::PharmaciesController < ApplicationController
  include Response

   # POST /api/pharmacies
   def create
    pharmacy = Pharmacy.create!(pharmacy_params)
    render_success(pharmacy)
    rescue ActiveRecord::RecordInvalid => e
      render_error(e.record.errors.full_messages.join(", "), :unprocessable_entity)
    end

  # GET /api/pharmacies
  # 支援 keyword / day_of_week / time
  def index
    pharmacies = Pharmacy.all

    if params[:keyword].present?
      pharmacies = pharmacies.where("name ILIKE ?", "%#{params[:keyword]}%")
    end

    if params[:day_of_week].present?
      pharmacies = pharmacies.joins(:pharmacy_opening_hours)
      time = params[:time]

      if time.present?
        pharmacies = pharmacies.where(
          "(pharmacy_opening_hours.day_of_week = :day AND pharmacy_opening_hours.open_time <= :time AND pharmacy_opening_hours.close_time >= :time) OR
           (pharmacy_opening_hours.day_of_week = :yesterday AND pharmacy_opening_hours.overnight = true AND pharmacy_opening_hours.close_time >= :time)",
          day: params[:day_of_week],
          yesterday: (params[:day_of_week].to_i - 1) % 7,
          time: time
        )
      else
        pharmacies = pharmacies.where(pharmacy_opening_hours: { day_of_week: params[:day_of_week] })
      end
    end

    pharmacies = pharmacies.distinct

    render_success(pharmacies.as_json(methods: :opening_hours_text))
  end


  # GET /api/pharmacies/:id
  def show
    pharmacy = Pharmacy.find(params[:id])
    render_success(
      pharmacy.as_json(methods: :opening_hours_text).merge(
        cash_balance: pharmacy.cash_balance.to_f
      )
    )
  rescue ActiveRecord::RecordNotFound
    render_error("Pharmacy not found", :not_found)
  end

  private

  def pharmacy_params
    params.require(:pharmacy).permit(:name, :cash_balance)
  end
end
