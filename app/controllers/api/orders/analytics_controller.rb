class Api::Orders::AnalyticsController < ApplicationController
    include Response
  
    # GET /api/orders/analytics/top_users
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
  
    # GET /api/orders/analytics/statistics
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