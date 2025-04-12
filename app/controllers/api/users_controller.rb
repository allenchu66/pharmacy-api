class Api::UsersController < ApplicationController
    include Response
  
    # GET /api/users
    def index
      users = User.all
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
  