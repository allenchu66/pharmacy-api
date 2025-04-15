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
                  mask_id: item.mask.mask_type.id,
                  mask_name: item.mask.mask_type.name,
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
  
      mask_type_summary= OrderItem
                       .joins(:order,mask: :mask_type)
                       .where(orders: { created_at: start_date..end_date })
                       .select('mask_types.id AS mask_type_id, mask_types.name AS mask_type_name, SUM(order_items.quantity) AS total_quantity, SUM(order_items.price * order_items.quantity) AS total_amount')
                       .group('mask_types.id, mask_types.name')
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
        mask_summary:mask_type_summary.map { |m| {
          mask_id: m.mask_type_id,
          mask_name: m.mask_type_name,
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