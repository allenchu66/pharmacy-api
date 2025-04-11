class Api::PharmaciesController < ApplicationController
    include Response
  
    #GET /api/pharmacies
    def index
      pharmacies = Pharmacy.all
      render_success(pharmacies)
    end
  
    #GET /api/pharmacies/:id
    def show
      pharmacy = Pharmacy.find(params[:id])
      render_success(pharmacy)
    rescue ActiveRecord::RecordNotFound
      render_error("Pharmacy not found", :not_found)
    end
  end
  