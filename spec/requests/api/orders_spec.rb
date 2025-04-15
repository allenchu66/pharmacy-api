require 'swagger_helper'

RSpec.describe 'api/orders', type: :request do
  path '/api/orders' do
    get 'Get all orders (support filters & keyword search)' do
      tags 'Orders'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, description: 'Keyword search by user or pharmacy name'
      parameter name: :user_id, in: :query, type: :integer, description: 'Filter by user ID'
      parameter name: :pharmacy_id, in: :query, type: :integer, description: 'Filter by pharmacy ID'
      parameter name: :price_min, in: :query, type: :number, description: 'Minimum total price'
      parameter name: :price_max, in: :query, type: :number, description: 'Maximum total price'
      parameter name: :start_date, in: :query, type: :string, description: 'Start date (yyyy-mm-dd)'
      parameter name: :end_date, in: :query, type: :string, description: 'End date (yyyy-mm-dd)'

      response '200', 'Success' do
        schema type: :object,
          properties: {
            status: { type: :string },
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  user_id: { type: :integer },
                  user_name: { type: :string },
                  pharmacy_id: { type: :integer },
                  pharmacy_name: { type: :string },
                  total_price: { type: :number },
                  created_at: { type: :string, format: :date_time },
                  items: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        mask_type: {
                          type: :object,
                          properties: {
                            id: { type: :integer },
                            name: { type: :string }
                          }
                        },
                        price: { type: :number },
                        quantity: { type: :integer }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:user) { create(:user) }
        let(:pharmacy) { create(:pharmacy) }
        let!(:order) { create(:order, user: user, pharmacy: pharmacy, total_price: 300, created_at: '2025-04-12') }

        let(:keyword) { nil }
        let(:user_id) { nil }
        let(:pharmacy_id) { nil }
        let(:price_min) { nil }
        let(:price_max) { nil }
        let(:start_date) { nil }
        let(:end_date) { nil }

        context 'without any filters' do
          run_test!
        end

        context 'with keyword' do
          let(:keyword) { 'Allen' }
          run_test!
        end

        context 'with user_id' do
          let(:user_id) { user.id }
          run_test!
        end

        context 'with pharmacy_id' do
          let(:pharmacy_id) { pharmacy.id }
          run_test!
        end

        context 'with price_min' do
          let(:price_min) { 100 }
          run_test!
        end

        context 'with start_date and end_date' do
          let(:start_date) { '2025-04-12' }
          let(:end_date) { '2025-04-12' }
          run_test!
        end
      end
    end
  end

  path '/api/orders/{id}' do
    get 'Get a specific order' do
      tags 'Orders'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Order ID'

      let(:user) { create(:user) }
      let(:pharmacy) { create(:pharmacy) }
      let(:mask_type) { create(:mask_type) }
      let(:mask) { create(:mask, pharmacy: pharmacy, mask_type: mask_type) }
      let(:order) { create(:order, user: user, pharmacy: pharmacy, total_price: 200) }
      let!(:order_item) { create(:order_item, order: order, mask: mask) }
      let(:id) { order.id }

      response '200', 'Success' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     user_name: { type: :string },
                     pharmacy_name: { type: :string },
                     total_price: { type: :number },
                     created_at: { type: :string, format: :date_time },
                     items: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           mask_name: { type: :string },
                           mask_type: {
                             type: :object,
                             properties: {
                               id: { type: :integer },
                               name: { type: :string }
                             }
                           },
                           price: { type: :number },
                           quantity: { type: :integer }
                         }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response '404', 'Order not found' do
        let(:id) { -1 }

        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string }
               }

        run_test!
      end
    end
  end

  path '/api/orders' do
    post 'Create a new order (support multiple masks)' do
      tags 'Orders'
      consumes 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                mask_id: { type: :integer },
                quantity: { type: :integer }
              },
              required: %w[mask_id quantity]
            }
          }
        },
        required: %w[user_id items]
      }

      let(:user) { create(:user) }
      let(:pharmacy) { create(:pharmacy) }
      let(:mask_type) { create(:mask_type) }
      let(:mask) { create(:mask, pharmacy: pharmacy, mask_type: mask_type) }

      response '200', 'Success' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     message: { type: :string }
                   }
                 }
               }

        context 'when request is valid' do
          let(:body) do
            {
              user_id: user.id,
              items: [
                { mask_id: mask.id, quantity: 2 }
              ]
            }
          end

          run_test!
        end
      end

      response '400', 'Validation failed' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string }
               }

        context 'when items is blank' do
          let(:body) do
            {
              user_id: user.id,
              items: []
            }
          end

          run_test!
        end

        context 'when quantity exceeds stock' do
          let(:body) do
            {
              user_id: user.id,
              items: [
                { mask_id: mask.id, quantity: 100 }
              ]
            }
          end

          run_test!
        end

        context 'when user cash is insufficient' do
          before { user.update!(cash_balance: 1) }

          let(:body) do
            {
              user_id: user.id,
              items: [
                { mask_id: mask.id, quantity: 2 }
              ]
            }
          end

          run_test!
        end
      end
    end
  end
end