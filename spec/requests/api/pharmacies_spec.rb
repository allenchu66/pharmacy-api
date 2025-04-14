require 'swagger_helper'

RSpec.describe 'api/pharmacies', type: :request do
  # GET /api/pharmacies
  path '/api/pharmacies' do
    get 'Get all pharmacies (supports keyword / day_of_week / time filter)' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, required: false, description: 'Fuzzy search pharmacy name (case-insensitive)'
      parameter name: :day_of_week, in: :query, type: :integer, required: false, description: 'Filter by opening day (0=Sun, 1=Mon, ..., 6=Sat)'
      parameter name: :time, in: :query, type: :string, required: false, description: 'Filter by time (format: HH:mm, e.g. 14:30)'

      response '200', 'Success' do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                opening_hours_text: { type: :string }
              }
            }
          }
        }

        before do
          Pharmacy.create(name: 'DFW Wellness')
          Pharmacy.create(name: 'Carepoint')
        end

        context 'without parameters' do
          run_test!
        end

        context 'with keyword' do
          let(:keyword) { 'DFW' }
          run_test!
        end

        context 'with day_of_week' do
          let(:day_of_week) { 1 }
          run_test!
        end

        context 'with time' do
          let(:time) { '14:30' }
          run_test!
        end

        context 'with keyword + day_of_week + time' do
          let(:keyword) { 'Care' }
          let(:day_of_week) { 2 }
          let(:time) { '09:00' }
          run_test!
        end
      end
    end
  end

  # GET /api/pharmacies/{id}
  path '/api/pharmacies/{id}' do
    get 'Get pharmacy details' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', 'Success' do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              cash_balance: { type: :number },
              opening_hours_text: { type: :string }
            }
          }
        }

        let(:id) { Pharmacy.create(name: 'DFW Wellness', cash_balance: 1000.5).id }
        run_test!
      end

      response '404', 'Not found' do
        schema type: :object, properties: {
          status: { type: :string },
          data: { type: :null }
        }

        let(:id) { -1 }
        run_test!
      end
    end
  end

  # GET /api/pharmacies/{pharmacy_id}/masks
  path '/api/pharmacies/{pharmacy_id}/masks' do
    get 'Get all masks of a pharmacy' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', 'Success' do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                price: { type: :number },
                stock: { type: :integer },
                pharmacy_id: { type: :integer },
                created_at: { type: :string, format: :date_time },
                updated_at: { type: :string, format: :date_time }
              }
            }
          }
        }

   
        before do
          pharmacy = Pharmacy.create!(name: 'Carepoint',cash_balance: 1000)
          Mask.create(name: 'Mask A', price: 10, stock: 100, pharmacy_id: pharmacy.id)
          Mask.create(name: 'Mask B', price: 15, stock: 50, pharmacy_id: pharmacy.id)
          @pharmacy_id = pharmacy.id
        end
        let(:pharmacy_id) { @pharmacy_id }
        run_test!
      end

      response '404', 'Not found' do
        schema type: :object, properties: {
          status: { type: :string },
          data: { type: :null }
        }

        let(:pharmacy_id) { -1 }
        run_test!
      end
    end
  end

  # POST /api/pharmacies
  path '/api/pharmacies' do
    post 'Create a new pharmacy' do
      tags 'Pharmacies'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :pharmacy, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          cash_balance: { type: :number }
        },
        required: %w[name cash_balance]
      }

      response '201', 'Created successfully' do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              cash_balance: { type: :number }
            }
          }
        }

        let(:pharmacy) { { name: 'Tainan Pharmacy', cash_balance: 10000.0 } }
        run_test!
      end

      response '422', 'Validation failed' do
        schema type: :object, properties: {
          status: { type: :string },
          message: { type: :string }
        }

        let(:pharmacy) { { name: '', cash_balance: -100 } }
        run_test!
      end
    end
  end
end
