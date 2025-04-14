class Api::UsersController < ApplicationController
    include Response

    # POST /api/users
    def create
      user = User.new(user_params)
      if user.save
        render_success(user)
      else
        render_error(user.errors.full_messages.join(', '), :unprocessable_entity)
      end  
    end
  
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
      render_success(user)
    rescue ActiveRecord::RecordNotFound
      render_error("User not found", :not_found)
    end

    private
    def user_params
      params.permit(:name, :phone_number, :cash_balance)
    end

  end
  