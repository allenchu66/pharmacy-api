require 'swagger_helper'

RSpec.describe 'api/pharmacies/add_funds', type: :request do
  path '/api/pharmacies/{pharmacy_id}/add_funds' do
    post 'Add funds to pharmacy' do
      tags 'Pharmacies'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :integer }
        },
        required: ['amount']
      }

      let!(:pharmacy) { create(:pharmacy, cash_balance: 1000) }
      let(:pharmacy_id) { pharmacy.id }
      let(:body) { { amount: 500 } }

      response '200', 'Success' do
        let(:body) { { amount: 500 } }

        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              message: { type: :string },
              cash_balance: { type: :number }
            }
          }
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['cash_balance']).to eq(1500.0)
        end
      end

      response '422', 'Invalid amount' do
        let(:body) { { amount: 0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
        end
      end

      response '404', 'Pharmacy not found' do
        let(:pharmacy_id) { -1 }
        let(:body) { { amount: 500 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
          expect(json['data']).to be_nil
        end
      end
    end
  end
end
