require 'swagger_helper'

RSpec.describe 'api/mask_purchases', type: :request do
  path '/api/pharmacies/{pharmacy_id}/mask_purchases' do
    post 'Pharmacy purchase multiple masks' do
      tags 'MaskPurchases'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          purchases: {
            type: :array,
            items: {
              type: :object,
              properties: {
                mask_type_id: { type: :integer, description: 'MaskType ID' },
                quantity: { type: :integer, description: 'Quantity to purchase' },
                unit_price: { type: :number, format: :float, description: 'Unit price of the mask' }
              },
              required: %w[mask_type_id quantity unit_price]
            }
          }
        },
        required: ['purchases']
      }

      let(:pharmacy) { create(:pharmacy) }
      let(:pharmacy_id) { pharmacy.id }

      response '200', 'Success' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     message: { type: :string },
                     total_price: { type: :number },
                     pharmacy: { type: :object },
                     masks: { type: :array }
                   }
                 }
               }
        let(:body) do
        {
          purchases: [
            { mask_type_id: create(:mask_type).id, quantity: 10, unit_price: 5 },
            { mask_type_id: create(:mask_type).id, quantity: 5, unit_price: 8 }
          ]
        }
        end              

        run_test!
      end

      response '422', 'Invalid Request' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string }
               }
      
        context 'when mask_type not found' do
          let(:body) do
            {
              purchases: [
                { mask_type_id: 9999, quantity: 10, unit_price: 5 }
              ]
            }
          end
      
          run_test!
        end
      
        context 'when invalid quantity or unit_price' do
          let(:body) do
            {
              purchases: [
                { mask_type_id: create(:mask_type).id, quantity: 0, unit_price: -1 }
              ]
            }
          end
      
          run_test!
        end
      
        context 'when not enough cash balance' do
          let(:body) do
            {
              purchases: [
                { mask_type_id: create(:mask_type).id, quantity: 1000, unit_price: 999 }
              ]
            }
          end
      
          run_test!
        end
      end
      
    end
  end
end
