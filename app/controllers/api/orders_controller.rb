class Api::OrdersController < ApplicationController
  include Response

  # GET /api/orders
  def index
    orders = Order.includes(:user, :pharmacy, order_items: :mask).order(created_at: :desc)

    # keyword 搜尋 (user_name or pharmacy_name)
    if params[:keyword].present?
      keyword = "%#{params[:keyword]}%"
      orders = orders.where("users.name ILIKE :keyword OR pharmacies.name ILIKE :keyword", keyword: keyword)
                    .references(:user, :pharmacy)
    end

    # user_id 篩選
    orders = orders.where(user_id: params[:user_id]) if params[:user_id].present?

    # pharmacy_id 篩選
    orders = orders.where(pharmacy_id: params[:pharmacy_id]) if params[:pharmacy_id].present?

    # 價格 >= min
    orders = orders.where("total_price >= ?", params[:price_min].to_f) if params[:price_min].present?

    # 價格 <= max
    orders = orders.where("total_price <= ?", params[:price_max].to_f) if params[:price_max].present?


    # 起始時間
    if params[:start_date].present?
      orders = orders.where("orders.created_at >= ?", params[:start_date].to_date.beginning_of_day)
    end

    # 結束時間
    if params[:end_date].present?
      orders = orders.where("orders.created_at <= ?", params[:end_date].to_date.end_of_day)
    end
    data = orders.map do |order|
      {
        id: order.id,
        user_id: order.user_id,
        user_name: order.user.name,
        pharmacy_id: order.pharmacy_id,
        pharmacy_name: order.pharmacy.name,
        total_price: order.total_price.to_f,
        created_at: order.created_at,
        items: order.order_items.map do |item|
          {
            mask_type: {
              id: item.mask.mask_type.id,
              name: item.mask.mask_type.name
            },
            price: item.price.to_f,
            quantity: item.quantity
          }
        end
      }
    end

    render_success(data)
  end

  # GET /api/orders/:id
  def show
    order = Order.find(params[:id])
    data = {
      id: order.id,
      user_name: order.user.name,
      pharmacy_name: order.pharmacy.name,
      total_price: order.total_price.to_f,
      created_at: order.created_at,
      items: order.order_items.map do |item|
        {
          mask_type: {
            id: item.mask.mask_type.id,
            name: item.mask.mask_type.name
          },
          price: item.price.to_f,
          quantity: item.quantity
        }
      end
    }
    render_success(data)
  rescue ActiveRecord::RecordNotFound => e
    render_error(e.message, :not_found)
  end

  # POST /api/orders
  def create
    ActiveRecord::Base.transaction do
      user = User.find(params[:user_id])
      items = params[:items]
  
      return render_error("Items can't be blank", :bad_request) if items.blank?
      return render_error("Invalid item format", :bad_request) unless items.all? { |item| item[:mask_id] && item[:quantity] }
  
      total_price = 0
      order_items = []

      items.each do |item|
        mask = Mask.find(item[:mask_id])
        quantity = item[:quantity].to_i
  
        return render_error("Quantity must greater than 0", :bad_request) if quantity <= 0
        return render_error("Mask stock not enough", :bad_request) if mask.stock < quantity
  
        total_price += mask.price * quantity
        order_items << { mask: mask, quantity: quantity, price: mask.price }
      end

      pharmacy_ids = order_items.map { |item| item[:mask].pharmacy_id }.uniq
      return render_error("Masks must belong to the same pharmacy", :bad_request) if pharmacy_ids.size > 1
  
      return render_error("User cash not enough", :bad_request) if user.cash_balance < total_price
  
      # 建立訂單
      order = Order.create!(user: user, pharmacy: order_items.first[:mask].pharmacy, total_price: total_price)
  
      # 建立訂單明細
      order_items.each do |item|
        OrderItem.create!(order: order, mask: item[:mask], quantity: item[:quantity], price: item[:price])
        item[:mask].update!(stock: item[:mask].stock - item[:quantity])
      end
  
      # 更新 User 與 Pharmacy 餘額
      pharmacy = order_items.first[:mask].pharmacy
      user.update!(cash_balance: user.cash_balance - total_price)
      pharmacy.update!(cash_balance: pharmacy.cash_balance + total_price)
    end
  
    render_success(message: "Order success")
  
  rescue ActiveRecord::RecordNotFound => e
    render_error(e.message, :not_found)
  rescue => e
    ogger.error "🔥 ERROR: #{e.message}"
    logger.error e.backtrace.join("\n")
    render_error("Unexpected error", :internal_server_error)
  end
  
end
