require 'swagger_helper'

RSpec.describe 'api/pharmacies', type: :request do
  path '/api/pharmacies/{id}' do
    get('取得單一藥局') do
      tags 'Pharmacies'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'

      let!(:pharmacy) { create(:pharmacy) }  # 這行最重要
      let(:id) { pharmacy.id }

      response(200, '成功') do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              cash_balance: { type: :number },
              opening_hours: { type: :string },
              masks: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    price: { type: :number },
                    stock: { type: :integer }
                  }
                }
              }
            }
          }
        }

        run_test!
      end
    end
  end
end
