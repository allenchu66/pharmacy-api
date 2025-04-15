require 'swagger_helper'

RSpec.describe 'api/mask_types', type: :request do
  path '/api/mask_types' do
    get 'Get all MaskTypes (support search by id / keyword)' do
      tags 'MaskTypes'
      produces 'application/json'

      parameter name: :id, in: :query, type: :integer, required: false, description: 'Filter by MaskType ID'
      parameter name: :keyword, in: :query, type: :string, required: false, description: 'Fuzzy search by name'

      response(200, 'Success') do
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

        let!(:mask_type1) { create(:mask_type, name: 'Medical Mask (Blue)') }
        let!(:mask_type2) { create(:mask_type, name: 'Medical Mask (Green)') }

        context 'Without conditions' do
          run_test!
        end

        context 'Search by id' do
          let(:id) { mask_type1.id }
          run_test!
        end

        context 'Search by keyword' do
          let(:keyword) { 'Blue' }
          run_test!
        end
      end
    end
  end

  path '/api/mask_types/{id}' do
    get 'Get specific MaskType' do
      tags 'MaskTypes'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'MaskType ID'

      let(:mask_type) { create(:mask_type, name: 'Medical Mask (Blue)') }
      let(:id) { mask_type.id }

      response(200, 'Success') do
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

      response(404, 'MaskType not found') do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/mask_types' do
    post 'Create MaskType' do
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

      response(200, 'Success') do
        let(:mask_type) { { name: 'Medical Mask (Red)', description: 'Beautiful red mask', color: 'Red', size: 'M' } }
        run_test!
      end

      response(422, 'Validation failed') do
        let(:mask_type) { { name: '' } }
        run_test!
      end
    end
  end
end
