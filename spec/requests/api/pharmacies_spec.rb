require 'swagger_helper'

RSpec.describe 'api/pharmacies', type: :request do
  path '/api/pharmacies' do
    get '取得所有藥局（支援 keyword / day_of_week / time 篩選）' do
      tags 'Pharmacies'
      produces 'application/json'
      parameter name: :keyword, in: :query, type: :string, required: false,description: '模糊搜尋藥局名稱'
      parameter name: :day_of_week, in: :query, type: :integer, required: false,description: '篩選營業日（0=週日）'
      parameter name: :time, in: :query, type: :string, required: false,description: '篩選時間（HH:mm）'

      response '200', '成功' do
        schema type: :object,
          properties: {
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

        run_test!
      end
    end
  end

  path '/api/pharmacies/{id}' do
    get '取得藥局詳細資料' do
      tags 'Pharmacies'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', '成功' do
        schema type: :object,
          properties: {
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
        let(:id) { -1 }
        run_test!
      end
    end
  end

  path '/api/pharmacies/{pharmacy_id}/masks' do
    get '取得某藥局的所有口罩' do
      tags 'Pharmacies'
      produces 'application/json'
      parameter name: :pharmacy_id, in: :path, type: :integer, required: false,description: 'Pharmacy ID'

      response '200', '成功' do
        schema type: :object,
          properties: {
            status: { type: :string },
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  price: { type: :string },
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
    end
  end
end