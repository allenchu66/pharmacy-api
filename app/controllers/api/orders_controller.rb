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
            mask_name: item.mask.name,
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
          mask_name: item.mask.name,
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
      mask = Mask.find(params[:mask_id])
      pharmacy = mask.pharmacy

      quantity = params[:quantity].to_i
      total_price = mask.price * quantity

      raise StandardError, "Mask stock not enough" if mask.stock < quantity
      raise StandardError, "User cash not enough" if user.cash_balance < total_price

      order = Order.create!(
        user: user,
        pharmacy: pharmacy,
        total_price: total_price
      )

      OrderItem.create!(
        order: order,
        mask: mask,
        quantity: quantity,
        price: mask.price
      )

      user.update!(cash_balance: user.cash_balance - total_price)
      pharmacy.update!(cash_balance: pharmacy.cash_balance + total_price)
      mask.update!(stock: mask.stock - quantity)
    end

    render_success(message: "Order success")
  rescue ActiveRecord::RecordNotFound => e
    render_error(e.message, :not_found)
  rescue StandardError => e
    render_error(e.message, :unprocessable_entity)
  end
end
