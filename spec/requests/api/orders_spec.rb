require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/orders', type: :request do
  include FactoryBot::Syntax::Methods
  path '/api/orders' do
    post('建立訂單') do
      tags 'Orders'
      consumes 'application/json'

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          pharmacy_id: { type: :integer },
          mask_id: { type: :integer },
          quantity: { type: :integer }
        },
        required: ['user_id', 'pharmacy_id', 'mask_id', 'quantity']
      }

      response(200, '成功') do
        let!(:user) { create(:user) }
        let!(:pharmacy) { create(:pharmacy) }
        let!(:mask) { create(:mask, pharmacy: pharmacy) }

        let(:order) do
          {
            user_id: user.id,
            pharmacy_id: pharmacy.id,
            mask_id: mask.id,
            quantity: 1
          }
        end

        schema type: :object, properties: {
          status: { type: :string },
          message: { type: :string }
        }

        run_test!
      end
    end
  end
end
