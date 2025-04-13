class Api::UsersController < ApplicationController
    include Response
  
    # GET /api/users
    def index
      users = User.all
      # 支援 name 模糊搜尋
      users = users.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
      # 支援 phone 搜尋
      users = users.where(phone_number: params[:phone_number]) if params[:phone_number].present?
      render_success(users)
    end
  
    # GET /api/users/:id
    def show
      user = User.find(params[:id])
      render_success(
        id: user.id,
        name: user.name,
        cash_balance: user.cash_balance.to_f
      )
    rescue ActiveRecord::RecordNotFound
      render_error("User not found", :not_found)
    end

  end
  