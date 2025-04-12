require 'swagger_helper'

RSpec.describe 'api/orders', type: :request do
  path '/api/orders' do
    get '取得所有訂單' do
      tags 'Orders'
      produces 'application/json'

      response '200', '成功' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     data: {
                       type: :array,
                       items: {
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
                                 price: { type: :number },
                                 quantity: { type: :integer }
                               }
                             }
                           }
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

  path '/api/orders/{id}' do
    get '取得指定訂單' do
      tags 'Orders'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Order ID'

      let(:user) { User.create!(name: 'Allen', cash_balance: 1000) }
      let(:pharmacy) { Pharmacy.create!(name: 'Test Pharmacy', cash_balance: 1000) }
      let(:mask) { Mask.create!(name: 'Test Mask', price: 100, stock: 10, pharmacy: pharmacy) }
      let(:order) { Order.create!(user: user, pharmacy: pharmacy, total_price: 200) }
      let(:id) { order.id }

      response '200', '成功' do
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
    end
  end

  path '/api/orders' do
    post '建立訂單' do
      tags 'Orders'
      consumes 'application/json'
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          mask_id: { type: :integer },
          quantity: { type: :integer }
        },
        required: %w[user_id mask_id quantity]
      }

      response '200', '建立成功' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer }
                   }
                 }
               }

        let(:user) { User.create!(name: 'Allen', cash_balance: 1000) }
        let(:pharmacy) { Pharmacy.create!(name: 'Test Pharmacy', cash_balance: 1000) }
        let(:mask) { Mask.create!(name: 'Test Mask', price: 100, stock: 10, pharmacy: pharmacy) }
        let(:order) { { user_id: user.id, mask_id: mask.id, quantity: 2 } }

        run_test!
      end
    end
  end
end
