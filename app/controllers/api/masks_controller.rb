class Api::MasksController < ApplicationController
    include Response
    def index
      pharmacy = Pharmacy.find(params[:pharmacy_id])
      masks = pharmacy.masks
  
      if params[:sort] == "price_asc"
        masks = masks.order(price: :asc)
      elsif params[:sort] == "price_desc"
        masks = masks.order(price: :desc)
      end
  
      render_success(masks)
    rescue ActiveRecord::RecordNotFound
      render_not_found("Pharmacy not found")
    end
  
    def filter
      pharmacy = Pharmacy.find(params[:pharmacy_id])
      masks = pharmacy.masks
  
      masks = masks.where("stock > ?", params[:stock_gt]) if params[:stock_gt].present?
      masks = masks.where("stock < ?", params[:stock_lt]) if params[:stock_lt].present?
      masks = masks.where("price >= ?", params[:price_min]) if params[:price_min].present?
      masks = masks.where("price <= ?", params[:price_max]) if params[:price_max].present?
  
      render_success(masks)
    rescue ActiveRecord::RecordNotFound
      render_not_found("Pharmacy not found")
    end
  end
  