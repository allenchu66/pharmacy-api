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
      render_success(user)
    rescue ActiveRecord::RecordNotFound
      render_error("User not found", :not_found)
    end
  end
  