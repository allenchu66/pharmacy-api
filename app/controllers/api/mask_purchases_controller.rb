class Api::MaskPurchasesController < ApplicationController
    include Response
  
    def create
      pharmacy = Pharmacy.find(params[:pharmacy_id])
      purchases = params[:purchases]
  
      return render_error("Purchases params are required", :unprocessable_entity) if purchases.blank?
  
      total_price = 0
      result_masks = []
  
      # Parse and validate all purchases
      parsed_purchases = purchases.map do |purchase|
        mask_type_id = purchase[:mask_type_id]
        quantity = purchase[:quantity].to_i
        unit_price = purchase[:unit_price].to_f
  
        raise ArgumentError, "Quantity must be greater than 0" if quantity <= 0
        raise ArgumentError, "Unit price must be >= 0" if unit_price < 0
  
        mask_type = MaskType.find_by(id: mask_type_id)
        raise ArgumentError, "MaskType ID #{mask_type_id} not found" if mask_type.nil?
  
        {
          mask_type: mask_type,
          quantity: quantity,
          unit_price: unit_price,
          total_price: quantity * unit_price
        }
      end
  
      # Calculate total price
      total_price = parsed_purchases.sum { |item| item[:total_price] }
  
      if pharmacy.cash_balance < total_price
        return render_error("Cash balance not enough", :unprocessable_entity)
      end
  
      ActiveRecord::Base.transaction do
        # Update pharmacy balance
        pharmacy.update!(cash_balance: pharmacy.cash_balance - total_price)
  
        parsed_purchases.each do |item|
          mask_type = item[:mask_type]
          quantity = item[:quantity]
          unit_price = item[:unit_price]
  
          # Check if the pharmacy already has this mask (by mask_type)
          mask = Mask.find_by(pharmacy_id: pharmacy.id, mask_type_id: mask_type.id)
  
          if mask
            # If mask exists, increase stock
            mask.update!(stock: mask.stock + quantity,unit_price: unit_price)
          else
            # If not, create a new mask for this pharmacy
            mask = Mask.create!(
              pharmacy: pharmacy,
              mask_type: mask_type,
              unit_price: unit_price,
              stock: quantity
            )
          end
  
          # Create a mask purchase record
          MaskPurchase.create!(
            pharmacy: pharmacy,
            mask: mask,
            quantity: quantity,
            unit_price: unit_price,
            total_price: quantity * unit_price
          )
  
          result_masks << mask
        end
      end
  
      render_success(
        message: "Purchase successfully",
        total_price: total_price,
        pharmacy: pharmacy,
        masks: result_masks
      )
    rescue ArgumentError => e
      render_error(e.message, :unprocessable_entity)
    rescue ActiveRecord::RecordNotFound => e
      render_error(e.message, :not_found)
    end
  end
  