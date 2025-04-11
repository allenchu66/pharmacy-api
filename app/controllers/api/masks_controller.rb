class Api::MasksController < ApplicationController
    include Response
    #GET /api/pharmacies/:pharmacy_id/masks?sort=price_asc
    def index
      pharmacy = Pharmacy.find(params[:pharmacy_id])
      masks = pharmacy.masks
  
      # 判斷排序條件
      case params[:sort]
      when "price_asc"
        masks = masks.order(price: :asc)
      when "price_desc"
        masks = masks.order(price: :desc)
      end
  
      render_success(masks)
    rescue ActiveRecord::RecordNotFound
      render_error("Pharmacy not found", :not_found)
    end
  end
  