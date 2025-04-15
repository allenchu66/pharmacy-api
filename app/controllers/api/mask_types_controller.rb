class Api::MaskTypesController < ApplicationController
    include Response
    # GET /api/mask_types
    def index
        mask_types = MaskType.all
        mask_types = mask_types.where(id: params[:id]) if params[:id].present?

        if params[:keyword].present?
            keyword = params[:keyword]
        
            mask_types = mask_types
              .select("mask_types.*, POSITION(#{ActiveRecord::Base.connection.quote(keyword)} IN name) AS position_order")
              .where("name ILIKE ?", "%#{keyword}%")
              .order(Arel.sql("
                CASE 
                  WHEN POSITION(#{ActiveRecord::Base.connection.quote(keyword)} IN name) = 0 THEN 1 
                  ELSE 0 
                END, 
                position_order ASC
              "))
          end
        
        render_success(mask_types)
    end

    # GET /api/mask_types/:id
    def show
        mask_type = MaskType.find(params[:id])
        render_success(mask_type)
    rescue ActiveRecord::RecordNotFound
        render_error("MaskType not found", :not_found)
    end
    # POST /api/mask_types
    def create
        mask_type = MaskType.new(mask_type_params)

        if mask_type.save
            render_success(mask_type)
        else
            render_error(mask_type.errors.full_messages.join(', '), :unprocessable_entity)
        end
    end

    private

    def mask_type_params
        params.require(:mask_type).permit(:name, :description, :color, :size)
    end
end
