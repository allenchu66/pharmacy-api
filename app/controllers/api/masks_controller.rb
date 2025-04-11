class Api::MasksController < ApplicationController
  include Response

  # GET /api/masks/all
  def all
    masks = Mask.includes(:pharmacy).all
    result = masks.map do |mask|
      mask.as_json.merge(pharmacy: { id: mask.pharmacy.id, name: mask.pharmacy.name })
    end
  
    render_success(result)
  end

  # GET /api/masks/:id
  def detail
    mask = Mask.find(params[:id])
    render_success(mask)
  rescue ActiveRecord::RecordNotFound
    render_not_found("Mask not found")
  end

  # GET /api/pharmacies/:pharmacy_id/masks
  def index
    pharmacy = Pharmacy.find(params[:pharmacy_id])
    masks = pharmacy.masks

    case params[:sort]
    when "price_asc"
      masks = masks.order(price: :asc)
    when "price_desc"
      masks = masks.order(price: :desc)
    end

    render_success(masks)
  rescue ActiveRecord::RecordNotFound
    render_not_found("Pharmacy not found")
  end

  # GET /api/pharmacies/:pharmacy_id/masks/:id
  def show
    pharmacy = Pharmacy.find(params[:pharmacy_id])
    mask = pharmacy.masks.find(params[:id])
    render_success(mask)
  rescue ActiveRecord::RecordNotFound
    render_not_found("Pharmacy or Mask not found")
  end

  # GET /api/pharmacies/:pharmacy_id/masks/filter
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

  # GET /api/masks/search?keyword=xxx
  def search
    masks = Mask.includes(:pharmacy).where("name ILIKE ?", "%#{params[:keyword]}%")

    result = masks.map do |mask|
      mask.as_json.merge(pharmacy: { id: mask.pharmacy.id, name: mask.pharmacy.name })
    end

    render_success(result)
  end
end
