require 'swagger_helper'

RSpec.describe 'api/masks', type: :request do
  path '/api/masks' do
    get 'Get all masks (support search & filters)' do
      tags 'Masks'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, description: 'Keyword search by mask name'
      parameter name: :stock_gt, in: :query, type: :integer, description: 'Stock greater than'
      parameter name: :stock_lt, in: :query, type: :integer, description: 'Stock less than'
      parameter name: :price_min, in: :query, type: :number, description: 'Minimum price'
      parameter name: :price_max, in: :query, type: :number, description: 'Maximum price'
      parameter name: :sort, in: :query, type: :string, description: 'Sort by price_asc, price_desc, name_asc, or name_desc'

      let(:keyword) { '' }
      let(:stock_gt) { nil }
      let(:stock_lt) { nil }
      let(:price_min) { nil }
      let(:price_max) { nil }
      let(:sort) { nil }

      response(200, 'Success') do
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

        context 'without any parameters' do
          run_test!
        end

        context 'search by keyword' do
          let(:keyword) { 'Smile' }

          run_test!
        end

        context 'filter by stock_gt' do
          let(:stock_gt) { 10 }

          run_test!
        end

        context 'filter by stock_lt' do
          let(:stock_lt) { 5 }

          run_test!
        end

        context 'filter by price_min' do
          let(:price_min) { 10 }

          run_test!
        end

        context 'filter by price_max' do
          let(:price_max) { 50 }

          run_test!
        end

        context 'sort by price ascending' do
          let(:sort) { 'price_asc' }

          run_test!
        end

        context 'sort by price descending' do
          let(:sort) { 'price_desc' }

          run_test!
        end

        context 'sort by name ascending' do
          let(:sort) { 'name_asc' }

          run_test!
        end

        context 'sort by name descending' do
          let(:sort) { 'name_desc' }

          run_test!
        end

        context 'search with multiple conditions' do
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
