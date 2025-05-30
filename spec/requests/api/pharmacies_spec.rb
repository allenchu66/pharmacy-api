require 'swagger_helper'

RSpec.describe 'api/pharmacies', type: :request do
  # GET /api/pharmacies
  path '/api/pharmacies' do
    get 'Get all pharmacies (supports keyword / day_of_week / time filter)' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :keyword, in: :query, type: :string, required: false, description: 'Fuzzy search pharmacy name (case-insensitive)'
      parameter name: :day_of_week, in: :query, type: :integer, required: false, description: 'Filter by opening day (0=Sun, 1=Mon, ..., 6=Sat)'
      parameter name: :time, in: :query, type: :string, required: false, description: 'Filter by time (format: HH:mm, e.g. 14:30)'

      response '200', 'Success' do
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

        let!(:pharmacy_1) { Pharmacy.create!(name: 'DFW Wellness', cash_balance: 1000) }
        let!(:pharmacy_2) { Pharmacy.create!(name: 'Carepoint', cash_balance: 1000) }

        before do
          [pharmacy_1, pharmacy_2].each do |pharmacy|
            PharmacyOpeningHour.create!(
              pharmacy: pharmacy,
              day_of_week: 2,
              open_time: '08:00',
              close_time: '18:00'
            )
          end
        end

        context 'without parameters' do
          run_test!
        end

        context 'with keyword' do
          let(:keyword) { 'DFW' }
          run_test!
        end

        context 'with day_of_week' do
          let(:day_of_week) { 1 }
          run_test!
        end

        context 'with time' do
          let(:time) { '14:30' }
          run_test!
        end

        context 'with keyword + day_of_week + time' do
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
    get 'Get pharmacy details' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', 'Success' do
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

      response '404', 'Not found' do
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
    get 'Get all masks of a pharmacy' do
      tags 'Pharmacies'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'

      response '200', 'Success' do
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
                updated_at: { type: :string, format: :date_time },
                unit_price: { type: :number, nullable: true },
                mask_type: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string },
                      description: { type: :string, nullable: true },
                      color: { type: :string, nullable: true }
                    }
                  }
              }
            }
          }
        }

        before do
          pharmacy = Pharmacy.create!(name: 'Carepoint',cash_balance: 1000)
          mask_type_a = MaskType.create!(name: 'Mask A')
          mask_type_b = MaskType.create!(name: 'Mask B')

          Mask.create!(price: 10, stock: 100, pharmacy: pharmacy, mask_type: mask_type_a)
          Mask.create!(price: 15, stock: 50, pharmacy: pharmacy, mask_type: mask_type_b)
          @pharmacy_id = pharmacy.id
        end
        let(:pharmacy_id) { @pharmacy_id }
        run_test!
      end

      response '404', 'Not found' do
        schema type: :object, properties: {
          status: { type: :string },
          data: { type: :null }
        }

        let(:pharmacy_id) { -1 }
        run_test!
      end
    end
  end

  # POST /api/pharmacies
  path '/api/pharmacies' do
    post 'Create a new pharmacy' do
      tags 'Pharmacies'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :pharmacy, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          cash_balance: { type: :number },
          opening_hours: {
            type: :object,
            additionalProperties: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  open: { type: :string, example: '09:00' },
                  close: { type: :string, example: '18:00' }
                }
              }
            },
            example: {
              'Mon' => [{ open: '09:00', close: '18:00' }],
              'Tue' => [{ open: '09:00', close: '18:00' }],
              'Wed' => [{ open: '09:00', close: '18:00' }],
              'Thu' => [{ open: '09:00', close: '18:00' }],
              'Fri' => [{ open: '09:00', close: '18:00' }],
              'Sat' => [{ open: '10:00', close: '14:00' }],
              'Sun' => [{ open: '10:00', close: '14:00' }]
            }
          }
        },
        required: %w[name cash_balance opening_hours]
      }

      let(:pharmacy) do
        {
          name: 'Tainan Pharmacy',
          cash_balance: 10000.0,
          opening_hours: {
            'Mon' => [{ open: '09:00', close: '18:00' }],
            'Tue' => [],
            'Wed' => [{ open: '09:00', close: '18:00' }],
            'Thu' => [],
            'Fri' => [{ open: '09:00', close: '18:00' }],
            'Sat' => [{ open: '10:00', close: '14:00' }],
            'Sun' => []
          }
        }
      end

      response '201', 'Created successfully' do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              cash_balance: { type: :number }
            }
          }
        }
        run_test!
      end

      response '422', 'Validation failed' do
        schema type: :object, properties: {
          status: { type: :string },
          message: { type: :string }
        }

        let(:pharmacy) { { name: '', cash_balance: -100 , opening_hours: {} } }
        run_test!
      end
    end
  end

  path '/api/pharmacies/{pharmacy_id}/mask_purchases' do
    post 'Pharmacy purchase multiple masks' do
      tags 'Pharmacies'
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
                unit_price: { type: :number, format: :float, description: 'Unit price of the mask' },
                price: { type: :number, format: :float, description: 'Price of the mask' },
              },
              required: %w[mask_type_id quantity unit_price price]
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
            { mask_type_id: create(:mask_type).id, quantity: 10, unit_price: 5, price: 6 },
            { mask_type_id: create(:mask_type).id, quantity: 5, unit_price: 8, price: 9 }
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
                { mask_type_id: 9999, quantity: 10, unit_price: 5, price: 6 }
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

  path '/api/pharmacies/{pharmacy_id}/add_funds' do
    post 'Add funds to pharmacy' do
      tags 'Pharmacies'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :pharmacy_id, in: :path, type: :integer, description: 'Pharmacy ID'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :integer }
        },
        required: ['amount']
      }

      let!(:pharmacy) { create(:pharmacy, cash_balance: 1000) }
      let(:pharmacy_id) { pharmacy.id }
      let(:body) { { amount: 500 } }

      response '200', 'Success' do
        let(:body) { { amount: 500 } }

        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              message: { type: :string },
              cash_balance: { type: :number }
            }
          }
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['cash_balance']).to eq(1500.0)
        end
      end

      response '422', 'Invalid amount' do
        let(:body) { { amount: 0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
        end
      end

      response '404', 'Pharmacy not found' do
        let(:pharmacy_id) { -1 }
        let(:body) { { amount: 500 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
          expect(json['data']).to be_nil
        end
      end
    end
  end

  path '/api/pharmacies/{id}/opening_hours' do
    put 'Update pharmacy opening hours' do
      tags 'Pharmacies'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Pharmacy ID'
      parameter name: :opening_hours, in: :body, schema: {
        type: :object,
        properties: {
          opening_hours: {
            type: :object,
            example: {
              "Mon": [{ "open": "09:00", "close": "18:00" }],
              "Tue": [{ "open": "09:00", "close": "18:00" }],
              "Wed": [{ "open": "09:00", "close": "18:00" }],
              "Thu": [{ "open": "09:00", "close": "18:00" }],
              "Fri": [{ "open": "09:00", "close": "18:00" }],
              "Sat": [{ "open": "10:00", "close": "14:00" }],
              "Sun": []
            }
          }
        },
        required: ['opening_hours']
      }

      response '200', 'Opening hours updated' do
        let!(:pharmacy) { create(:pharmacy) }
        let(:id) { pharmacy.id }
        let(:opening_hours) do
          {
            opening_hours: {
              "Mon" => [{ "open" => "09:00", "close" => "18:00" }],
              "Tue" => [],
              "Wed" => [{ "open" => "09:00", "close" => "18:00" }],
              "Thu" => [],
              "Fri" => [],
              "Sat" => [],
              "Sun" => []
            }
          }
        end

        run_test!
      end

      response '404', 'Pharmacy not found' do
        let(:id) { 99999 } # 不存在的 pharmacy ID
        let(:opening_hours) do
          {
            opening_hours: {
              "Mon" => [{ "open" => "09:00", "close" => "18:00" }]
            }
          }
        end

        run_test!
      end

      response '422', 'Invalid input' do
        let!(:pharmacy) { create(:pharmacy) }
        let(:id) { pharmacy.id }
        let(:opening_hours) do
          {
            opening_hours: {
              "Mnn" => [{ "open" => "09:00", "close" => "18:00" }] # 錯誤 weekday
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/pharmacies/filter_by_mask_conditions' do
    get 'Filter pharmacies by mask conditions' do
      tags 'Pharmacies'
      produces 'application/json'
  
      parameter name: :mask_count_gt, in: :query, type: :integer, required: false,description: 'Optional. Return pharmacies with more than this number of mask products (e.g., 5)'

      parameter name: :mask_count_lt, in: :query, type: :integer, required: false,description: 'Optional. Return pharmacies with fewer than this number of mask products (e.g., 10)'

      parameter name: :mask_price_min, in: :query, type: :number, required: true,description: 'Required. Minimum mask price to filter mask products (e.g., 10.0)'

      parameter name: :mask_price_max, in: :query, type: :number, required: true,description: 'Required. Maximum mask price to filter mask products (e.g., 50.0)'

  
      # 200 成功 (有帶參數)
    response '200', 'Success with condition' do
      let(:mask_price_min) { 5.0 }
      let(:mask_price_max) { 15.0 }
      let(:mask_count_gt) { 0 }

      let!(:mask_type1) { create(:mask_type) }
      let!(:pharmacy1) { create(:pharmacy, name: 'A', cash_balance: 100) }
      let!(:mask1) { create(:mask, pharmacy: pharmacy1, mask_type: mask_type1, price: 10, stock: 10) }

      schema type: :object, properties: {
        status: { type: :string },
        data: {
          type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              mask_count: { type: :integer }
            }
          }
        }
      }

      run_test! do |response|
        json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json['data'].length).to be >= 1
      end
    end

    # 400 沒有帶參數
    response '400', 'Missing price range parameters' do
      let(:mask_price_min) { nil }
      let(:mask_price_max) { nil }
      run_test! do |response|
        json = JSON.parse(response.body)
        expect(response.status).to eq(400)
        expect(json['message']).to eq("Price range is required")
      end
    end
  end
end

  
  
  
end
