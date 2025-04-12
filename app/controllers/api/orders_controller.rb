class Api::OrdersController < ApplicationController
  include Response

  # 查詢所有訂單
  def index
    orders = Order.includes(:user, :pharmacy, order_items: :mask).order(created_at: :desc)
  
    data = orders.map do |order|
      {
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
    end
  
    render_success(data: data)
  end

  # 建立訂單
  def create
    ActiveRecord::Base.transaction do
      user = User.find(params[:user_id])
      mask = Mask.find(params[:mask_id])
      pharmacy = mask.pharmacy

      quantity = params[:quantity].to_i
      total_price = mask.price * quantity

      raise StandardError, "Mask stock not enough" if mask.stock < quantity
      raise StandardError, "User cash not enough" if user.cash_balance < total_price

      # 建立 Order
      order = Order.create!(
        user: user,
        pharmacy: pharmacy,
        total_price: total_price
      )

      # 建立 OrderItem
      OrderItem.create!(
        order: order,
        mask: mask,
        quantity: quantity,
        price: mask.price
      )

      # 更新 user, pharmacy, mask
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
