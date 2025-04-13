require 'swagger_helper'

RSpec.describe 'api/masks', type: :request do
  path '/api/masks' do
    get('取得所有口罩 (支援搜尋與篩選)') do
      tags 'Masks'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, description: '口罩名稱關鍵字'
      parameter name: :stock_gt, in: :query, type: :integer, description: '庫存大於'
      parameter name: :stock_lt, in: :query, type: :integer, description: '庫存小於'
      parameter name: :price_min, in: :query, type: :number, description: '價格大於等於'
      parameter name: :price_max, in: :query, type: :number, description: '價格小於等於'
      parameter name: :sort, in: :query, type: :string, description: '排序方式(price_asc、price_desc、name_asc、name_desc)'

      let(:keyword) { '' }
      let(:stock_gt) { nil }
      let(:stock_lt) { nil }
      let(:price_min) { nil }
      let(:price_max) { nil }
      let(:sort) { nil }

      response(200, '成功') do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                price: { type: :number },
                stock: { type: :integer },
                pharmacy: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                }
              }
            }
          }
        }

        context '無參數' do
          run_test!
        end

        context '搜尋 keyword' do
          let(:keyword) { 'Smile' }

          run_test!
        end

        context '篩選 stock_gt' do
          let(:stock_gt) { 10 }

          run_test!
        end

        context '篩選 stock_lt' do
          let(:stock_lt) { 5 }

          run_test!
        end

        context '篩選 price_min' do
          let(:price_min) { 10 }

          run_test!
        end

        context '篩選 price_max' do
          let(:price_max) { 50 }

          run_test!
        end

        context '排序 price_asc' do
          let(:sort) { 'price_asc' }

          run_test!
        end

        context '排序 price_desc' do
          let(:sort) { 'price_desc' }

          run_test!
        end

        context '排序 name_asc' do
          let(:sort) { 'name_asc' }

          run_test!
        end

        context '排序 name_desc' do
          let(:sort) { 'name_desc' }

          run_test!
        end

        context '複合條件搜尋' do
          let(:keyword) { 'Mask' }
          let(:stock_gt) { 5 }
          let(:stock_lt) { 20 }
          let(:price_min) { 10 }
          let(:price_max) { 100 }
          let(:sort) { 'price_asc' }

          run_test!
        end
      end
    end
  end
end
