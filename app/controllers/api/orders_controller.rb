class Api::OrdersController < ApplicationController
    include Response
  
    def create
      ActiveRecord::Base.transaction do
        user = User.find(params[:user_id])
        mask = Mask.find(params[:mask_id])
        pharmacy = mask.pharmacy
  
        quantity = params[:quantity].to_i
        total_price = mask.price * quantity
  
        raise StandardError, "Mask stock not enough" if mask.stock < quantity
        raise StandardError, "User cash not enough" if user.cash_balance < total_price
  
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
  