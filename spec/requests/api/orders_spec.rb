require 'swagger_helper'

RSpec.describe 'api/orders', type: :request do
  path '/api/orders' do
    get '取得所有訂單（支援多條件搜尋）' do
      tags 'Orders'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, required: false, description: '模糊搜尋 User 名稱 或 Pharmacy 名稱'
      parameter name: :user_id, in: :query, type: :integer, required: false, description: '指定 User ID'
      parameter name: :pharmacy_id, in: :query, type: :integer, required: false, description: '指定 Pharmacy ID'
      parameter name: :price_min, in: :query, type: :number, required: false, description: '訂單金額大於等於'
      parameter name: :price_max, in: :query, type: :number, required: false, description: '訂單金額小於等於'
      parameter name: :start_date, in: :query, type: :string, required: false, description: '起始日期 YYYY-MM-DD'
      parameter name: :end_date, in: :query, type: :string, required: false, description: '結束日期 YYYY-MM-DD'

      response '200', '成功' do
        schema type: :object, properties: {
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

        let(:user) { create(:user) }
        let(:pharmacy) { create(:pharmacy) }
        let!(:order) { create(:order, user: user, pharmacy: pharmacy, total_price: 300, created_at: '2025-04-12') }

        context '無參數' do
          run_test!
        end

        context '有 keyword' do
          let(:keyword) { 'Allen' }
          run_test!
        end

        context '有 user_id' do
          let(:user_id) { user.id }
          run_test!
        end

        context '有 pharmacy_id' do
          let(:pharmacy_id) { pharmacy.id }
          run_test!
        end

        context '有 price_min' do
          let(:price_min) { 100 }
          run_test!
        end

        context '有 start_date & end_date' do
          let(:start_date) { '2025-04-12' }
          let(:end_date) { '2025-04-12' }
          run_test!
        end
      end
    end
  end

  path '/api/orders/{id}' do
    get '取得指定訂單' do
      tags 'Orders'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Order ID'

      let(:user) { create(:user) }
      let(:pharmacy) { create(:pharmacy) }
      let(:mask) { create(:mask, pharmacy: pharmacy) }
      let(:order) { create(:order, user: user, pharmacy: pharmacy, total_price: 200) }
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
      parameter name: :body, in: :body, schema: {
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

        let(:user) { create(:user) }
        let(:pharmacy) { create(:pharmacy) }
        let(:mask) { create(:mask, pharmacy: pharmacy) }       
        let(:body) { { user_id: user.id, mask_id: mask.id, quantity: 2 } }
        run_test!
      end
    end
  end
end
