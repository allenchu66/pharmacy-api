class Api::PharmaciesController < ApplicationController
  include Response

   # POST /api/pharmacies
  def create
    ActiveRecord::Base.transaction do
      pharmacy = Pharmacy.create!(pharmacy_params)
  
      # 如果有傳 opening_hours
      if params[:opening_hours].present?
        create_opening_hours!(pharmacy, params[:opening_hours])
      end
  
      render_success(pharmacy, :created)
    end
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages.join(", "), :unprocessable_entity)
  end

  # GET /api/pharmacies
  # 支援 keyword / day_of_week / time
  def index
    pharmacies = Pharmacy.all

    if params[:keyword].present?
      keyword = params[:keyword]
      pharmacies = pharmacies
        .select("pharmacies.*, 
          POSITION(#{ActiveRecord::Base.connection.quote(keyword)} IN name) AS position_order")
        .where("name ILIKE ?", "%#{keyword}%")
        .order("position_order ASC")
    end
    
    if params[:day_of_week].present?
      pharmacies = pharmacies.joins(:pharmacy_opening_hours)
      time = params[:time]

      if time.present?
        parsed_time = Time.parse(time).strftime('%H:%M:%S')
        pharmacies = pharmacies.where(
          "(pharmacy_opening_hours.day_of_week = :day AND pharmacy_opening_hours.open_time <= :time AND pharmacy_opening_hours.close_time >= :time)",
          day: params[:day_of_week],
          time:  parsed_time
        )
      else
        pharmacies = pharmacies.where(pharmacy_opening_hours: { day_of_week: params[:day_of_week] })
      end
    end

    pharmacies = pharmacies.distinct.order(:id)

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

  # PUT /api/pharmacies/:pharmacy_id/opening_hours
  def opening_hours
    pharmacy = Pharmacy.find(params[:id])
    
    ActiveRecord::Base.transaction do
      # remove old data
      pharmacy.pharmacy_opening_hours.destroy_all
      create_opening_hours!(pharmacy, params[:opening_hours])
    end

    render_success(message: 'Opening hours updated successfully')
  rescue ActiveRecord::RecordNotFound
    render_error('Pharmacy not found', :not_found)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.message, :unprocessable_entity)  
  rescue => e
    render_error(e.message, :unprocessable_entity)
  end

  def filter_by_mask_conditions
    if params[:mask_price_min].blank? || params[:mask_price_max].blank?
      return render_error("Price range is required", :bad_request)
    end

    price_min = params[:mask_price_min].to_f
    price_max = params[:mask_price_max].to_f
    mask_count_gt = params[:mask_count_gt].to_i
    mask_count_lt = params[:mask_count_lt].to_i
  
    pharmacies = Pharmacy.joins(:masks)
                          .where("masks.price >= ?", price_min)
                          .where("masks.price <= ?", price_max)
                          .group("pharmacies.id")
                          .select("pharmacies.*, COUNT(masks.id) as mask_count")

    having_conditions = []  
    having_values = []

    if params[:mask_count_gt].present?
      having_conditions << "COUNT(masks.id) > ?"
      having_values << mask_count_gt
    end

    if params[:mask_count_lt].present?
      having_conditions << "COUNT(masks.id) < ?"
      having_values << mask_count_lt
    end

    if having_conditions.any?
      pharmacies = pharmacies.having(having_conditions.join(" AND "), *having_values)
    end
  
    result = pharmacies.map do |pharmacy|
      pharmacy.as_json.merge(mask_count: pharmacy.mask_count)
    end
  
    render_success(result)
  end

  private

  def pharmacy_params
    params.require(:pharmacy).permit(:name, :cash_balance)
  end

  def create_opening_hours!(pharmacy, opening_hours)
    opening_hours.each do |day, times|
      day_of_week = TimeParser::DAY_MAP[day]
      raise ActiveRecord::RecordInvalid.new(PharmacyOpeningHour.new), "Invalid day: #{day}" if day_of_week.nil?

      times.each do |time|
        open_time = Time.parse(time['open']).strftime('%H:%M:%S')
        close_time = Time.parse(time['close']).strftime('%H:%M:%S')
        
        if close_time > open_time
          PharmacyOpeningHour.create!(
            pharmacy:    pharmacy,
            day_of_week: day_of_week,
            open_time:   open_time,
            close_time:  close_time
          )
        else
          # 跨夜：拆成兩筆
          # 1) 當天 open -> 24:00
          PharmacyOpeningHour.create!(
            pharmacy:    pharmacy,
            day_of_week: day_of_week,
            open_time:   open_time,
            close_time:  '00:00'
          )
  
          # 2) 隔天 00:00 -> close
          next_day = (day_of_week + 1) % 7
          PharmacyOpeningHour.create!(
            pharmacy:    pharmacy,
            day_of_week: next_day,
            open_time:   '00:00',
            close_time:  close_time
          )
        end
      end
    end
  end 

end
