require 'swagger_helper'

RSpec.describe 'api/pharmacies', type: :request do
  # GET /api/pharmacies
  path '/api/pharmacies' do
    get '取得所有藥局（支援 keyword / day_of_week / time 篩選）' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, required: false, description: '模糊搜尋藥局名稱 (不區分大小寫)'
      parameter name: :day_of_week, in: :query, type: :integer, required: false, description: '篩選營業日 (0=週日, 1=週一, ... 6=週六)'
      parameter name: :time, in: :query, type: :string, required: false, description: '篩選時間 (格式: HH:mm，例如 14:30)'

      response '200', '成功' do
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

        context '無參數' do
          run_test!
        end

        context '有 keyword' do
          let(:keyword) { 'DFW' }
          run_test!
        end

        context '有 day_of_week' do
          let(:day_of_week) { 1 }
          run_test!
        end

        context '有 time' do
          let(:time) { '14:30' }
          run_test!
        end

        context '有 keyword + day_of_week + time' do
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
    get '取得藥局詳細資料' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', '成功' do
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

      response '404', '找不到資料' do
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
    get '取得某藥局的所有口罩' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', '成功' do
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
                pharmacy_id: { type: :integer },
                created_at: { type: :string, format: :date_time },
                updated_at: { type: :string, format: :date_time }
              }
            }
          }
        }

        let(:pharmacy_id) { Pharmacy.create(name: 'Carepoint').id }

        before do
          Mask.create(name: 'Mask A', price: 10, stock: 100, pharmacy_id: pharmacy_id)
          Mask.create(name: 'Mask B', price: 15, stock: 50, pharmacy_id: pharmacy_id)
        end

        run_test!
      end

      response '404', '找不到資料' do
        schema type: :object, properties: {
          status: { type: :string },
          data: { type: :null }
        }

        let(:pharmacy_id) { -1 }
        run_test!
      end
    end
  end
end
