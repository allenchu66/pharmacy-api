class Api::MasksController < ApplicationController
  include Response

   # GET /api/pharmacies/:pharmacy_id/masks
  def pharmacy_index
    pharmacy = Pharmacy.find_by(id: params[:pharmacy_id])
    return render_error("Pharmacy not found", :not_found) if pharmacy.nil?

    masks = pharmacy.masks
    render_success(masks.as_json(only: [:id, :name, :price, :stock, :pharmacy_id, :created_at, :updated_at]))
  end

  # GET /api/masks
  def index
    masks = Mask.includes(:pharmacy).all

    # filter
    masks = masks.where("stock > ?", params[:stock_gt].to_i) if params[:stock_gt].present?
    masks = masks.where("stock < ?", params[:stock_lt].to_i) if params[:stock_lt].present?
    masks = masks.where("price >= ?", params[:price_min].to_f) if params[:price_min].present?
    masks = masks.where("price <= ?", params[:price_max].to_f) if params[:price_max].present?

    # search
    masks = masks.where("name ILIKE ?", "%#{params[:keyword]}%") if params[:keyword]

    # sort
    if params[:sort] == 'name_asc'
      masks = masks.order(name: :asc)
    elsif params[:sort] == 'name_desc'
      masks = masks.order(name: :desc)
    elsif params[:sort] == 'price_asc'
      masks = masks.order(price: :asc)
    elsif params[:sort] == 'price_desc'
      masks = masks.order(price: :desc)
    end
    

    result = masks.map do |mask|
      mask.as_json.merge(pharmacy: { id: mask.pharmacy.id, name: mask.pharmacy.name })
    end

    render_success(result)
  end

  # GET /api/masks/:id
  def show
    mask = Mask.includes(:pharmacy).find(params[:id])
    render_success(mask.as_json.merge(pharmacy: { id: mask.pharmacy.id, name: mask.pharmacy.name }))
  rescue ActiveRecord::RecordNotFound
    render_error("Mask not found")
  end

end
