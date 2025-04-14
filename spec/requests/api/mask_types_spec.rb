require 'swagger_helper'

RSpec.describe 'api/mask_types', type: :request do
  path '/api/mask_types' do
    get '取得所有 MaskTypes (支援 id / keyword 搜尋)' do
      tags 'MaskTypes'
      produces 'application/json'

      parameter name: :id, in: :query, type: :integer, required: false, description: '指定 MaskType ID'
      parameter name: :keyword, in: :query, type: :string, required: false, description: '模糊搜尋 name'

      response(200, '成功') do
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
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     }
                   }
                 }
               }

        let!(:mask_type1) { create(:mask_type, name: '醫療口罩(藍)') }
        let!(:mask_type2) { create(:mask_type, name: '醫療口罩(綠)') }

        context '無條件' do
          run_test!
        end

        context '搜尋 id' do
          let(:id) { mask_type1.id }
          run_test!
        end

        context '模糊搜尋 keyword' do
          let(:keyword) { '藍' }
          run_test!
        end
      end
    end
  end

  path '/api/mask_types/{id}' do
    get '取得指定 MaskType' do
      tags 'MaskTypes'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'MaskType ID'

      let(:mask_type) { create(:mask_type, name: '醫療口罩(藍)') }
      let(:id) { mask_type.id }

      response(200, '成功') do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   }
                 }
               }

        run_test!
      end

      response(404, '找不到') do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/mask_types' do
    post '新增 MaskType' do
      tags 'MaskTypes'
      consumes 'application/json'
      parameter name: :mask_type, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          color: { type: :string },
          size: { type: :string }
        },
        required: ['name']
      }

      response(200, '成功') do
        let(:mask_type) { { name: '醫療口罩(紅)', description: '好看的紅色口罩', color: 'Red', size: 'M' } }
        run_test!
      end

      response(422, '失敗') do
        let(:mask_type) { { name: '' } }
        run_test!
      end
    end
  end
end
