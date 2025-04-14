class Api::Pharmacies::AddFundsController < ApplicationController
    include Response
  
    # POST /api/pharmacies/:pharmacy_id/add_funds
    def create
      pharmacy = Pharmacy.find_by(id: params[:pharmacy_id])
      return render_error("Pharmacy not found", :not_found) if pharmacy.nil?
  
      amount = params[:amount].to_i
      return render_error("Amount must be greater than 0", :unprocessable_entity) if amount <= 0
  
      pharmacy.update!(cash_balance: pharmacy.cash_balance + amount)
  
      render_success(
        message: "Add funds success",
        cash_balance: pharmacy.cash_balance.to_f
      )
    end
  end
  