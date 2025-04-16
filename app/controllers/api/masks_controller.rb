class Api::MasksController < ApplicationController
  include Response

   # GET /api/pharmacies/:pharmacy_id/masks
  def pharmacy_index
    pharmacy = Pharmacy.find_by(id: params[:pharmacy_id])
    return render_error("Pharmacy not found", :not_found) if pharmacy.nil?

    masks = pharmacy.masks.includes(:mask_type)
    # filter
    masks = masks.where("stock > ?", params[:stock_gt].to_i) if params[:stock_gt].present?
    masks = masks.where("stock < ?", params[:stock_lt].to_i) if params[:stock_lt].present?
    masks = masks.where("price >= ?", params[:price_min].to_f) if params[:price_min].present?
    masks = masks.where("price <= ?", params[:price_max].to_f) if params[:price_max].present?

     # search
    if params[:keyword].present?
      keyword = "%#{params[:keyword]}%"
      masks = masks.joins(:mask_type).where(
        "masks.name ILIKE :keyword OR mask_types.name ILIKE :keyword",
        keyword: keyword
      )
    end

     # sort
    if params[:sort].present?
      case params[:sort]
      when 'name_asc'
        masks = masks.joins(:mask_type).order('mask_types.name ASC')
      when 'name_desc'
        masks = masks.joins(:mask_type).order('mask_types.name DESC')
      when 'price_asc'
        masks = masks.order(price: :asc)
      when 'price_desc'
        masks = masks.order(price: :desc)
      end
    end
     
    render_success(
      masks.as_json(
        only: [:id, :name, :price, :unit_price ,:stock, :pharmacy_id, :created_at, :updated_at],
        include: {
          mask_type: {
            only: [:id, :name, :color, :category, :description]
          }
        }
      )
    )
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
    if params[:keyword].present?
      keyword = params[:keyword]
      masks = masks
      .joins(:mask_type)
        .select("masks.*, POSITION(#{ActiveRecord::Base.connection.quote(keyword)} IN mask_types.name) AS position_order")
        .where("mask_types.name ILIKE ?", "%#{keyword}%")
        .order(Arel.sql("
          CASE 
            WHEN POSITION(#{ActiveRecord::Base.connection.quote(keyword)} IN mask_types.name) = 0 THEN 1 
            ELSE 0 
          END, 
          position_order ASC
        "))
    end    
    # sort
    if params[:sort] == 'price_asc'
      masks = masks.order(price: :asc)
    elsif params[:sort] == 'price_desc'
      masks = masks.order(price: :desc)
    end
    

    result = masks.map do |mask|
      mask.as_json.merge(
        pharmacy: { id: mask.pharmacy.id, name: mask.pharmacy.name },
        mask_type: { id: mask.mask_type.id, name: mask.mask_type.name}
      )
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
