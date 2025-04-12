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

  # Top X Users API
  def top_users
    start_date = params[:start_date]
    end_date = params[:end_date]
    limit = params[:limit] || 5

    users = User
              .joins(orders: :order_items)
              .where(orders: { created_at: start_date..end_date })
              .select('users.id, users.name, SUM(order_items.price * order_items.quantity) AS total_amount, SUM(order_items.quantity) AS total_quantity')
              .group('users.id')
              .order('total_amount DESC')
              .limit(limit)

    data = users.map do |user|
      orders = user.orders
                   .includes(:pharmacy, order_items: :mask)
                   .where(created_at: start_date..end_date)

      {
        user_id: user.id,
        user_name: user.name,
        total_amount: user.total_amount.to_f,
        total_quantity: user.total_quantity.to_i,
        orders: orders.map do |order|
          {
            pharmacy_name: order.pharmacy.name,
            total_price: order.total_price.to_f,
            created_at: order.created_at,
            items: order.order_items.map do |item|
              {
                mask_id: item.mask.id,
                mask_name: item.mask.name,
                price: item.price.to_f,
                quantity: item.quantity
              }
            end
          }
        end
      }
    end

    render_success(data: data)
  end

  # Statistics API
  def statistics
    start_date = params[:start_date]
    end_date = params[:end_date]

    stats = OrderItem
              .joins(:order)
              .where(orders: { created_at: start_date..end_date })
              .select('SUM(order_items.quantity) AS total_quantity, SUM(order_items.price * order_items.quantity) AS total_amount')
              .take

    mask_summary = OrderItem
                     .joins(:order, :mask)
                     .where(orders: { created_at: start_date..end_date })
                     .select('masks.id, masks.name, SUM(order_items.quantity) AS total_quantity, SUM(order_items.price * order_items.quantity) AS total_amount')
                     .group('masks.id, masks.name')
                     .order('total_quantity DESC')

    pharmacy_summary = OrderItem
                         .joins(order: :pharmacy)
                         .where(orders: { created_at: start_date..end_date })
                         .select('pharmacies.id, pharmacies.name, SUM(order_items.quantity) AS total_quantity, SUM(order_items.price * order_items.quantity) AS total_amount')
                         .group('pharmacies.id, pharmacies.name')
                         .order('total_quantity DESC')

    render_success(data: {
      total_quantity: stats.total_quantity.to_i,
      total_amount: stats.total_amount.to_f,
      mask_summary: mask_summary.map { |m| {
        mask_id: m.id,
        mask_name: m.name,
        total_quantity: m.total_quantity.to_i,
        total_amount: m.total_amount.to_f
      }},
      pharmacy_summary: pharmacy_summary.map { |p| {
        pharmacy_id: p.id,
        pharmacy_name: p.name,
        total_quantity: p.total_quantity.to_i,
        total_amount: p.total_amount.to_f
      }}
    })
  end
end
