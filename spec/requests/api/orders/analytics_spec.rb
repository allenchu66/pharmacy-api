require 'swagger_helper'

RSpec.describe 'api/orders/analytics', type: :request do
  path '/api/orders/analytics/top_users' do
    get 'Top Users 排行榜' do
      tags 'Orders Analytics'
      produces 'application/json'
      parameter name: :start_date, in: :query, type: :string, required: true, description: '起始日期 yyyy-mm-dd'
      parameter name: :end_date, in: :query, type: :string, required: true, description: '結束日期 yyyy-mm-dd'
      parameter name: :limit, in: :query, type: :integer, required: false, description: '前幾名（預設5）'

      let(:start_date) { '2025-04-01' }
      let(:end_date) { '2025-04-12' }
      let(:limit) { 5 }

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
                           user_id: { type: :integer },
                           user_name: { type: :string },
                           total_amount: { type: :number },
                           total_quantity: { type: :integer },
                           orders: {
                             type: :array,
                             items: {
                               type: :object,
                               properties: {
                                 pharmacy_name: { type: :string },
                                 total_price: { type: :number },
                                 created_at: { type: :string, format: :date_time },
                                 items: {
                                   type: :array,
                                   items: {
                                     type: :object,
                                     properties: {
                                       mask_id: { type: :integer },
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
                   }
                 }
               }

        run_test!
      end
    end
  end

  path '/api/orders/analytics/statistics' do
    get '訂單統計' do
      tags 'Orders Analytics'
      produces 'application/json'
      parameter name: :start_date, in: :query, type: :string, required: true, description: '起始日期 yyyy-mm-dd'
      parameter name: :end_date, in: :query, type: :string, required: true, description: '結束日期 yyyy-mm-dd'

      let(:start_date) { '2025-04-01' }
      let(:end_date) { '2025-04-12' }

      response '200', '成功' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     total_quantity: { type: :integer },
                     total_amount: { type: :number },
                     mask_summary: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           mask_id: { type: :integer },
                           mask_name: { type: :string },
                           total_quantity: { type: :integer },
                           total_amount: { type: :number }
                         }
                       }
                     },
                     pharmacy_summary: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           pharmacy_id: { type: :integer },
                           pharmacy_name: { type: :string },
                           total_quantity: { type: :integer },
                           total_amount: { type: :number }
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
