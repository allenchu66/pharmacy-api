require 'swagger_helper'

RSpec.describe 'api/users', type: :request do
  path '/api/users' do
    get 'Get all users (support search by name / phone_number)' do
      tags 'Users'
      produces 'application/json'

      parameter name: :name, in: :query, type: :string, description: 'Keyword to search user name'
      parameter name: :phone_number, in: :query, type: :string, description: 'User phone number'

      response '200', 'Success - No Condition' do
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
                       phone_number: { type: :string },
                       cash_balance: { type: :number }
                     }
                   }
                 }
               }

        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Bob', phone_number: '0987654321', cash_balance: 200)
        end

        let(:name) { nil }
        let(:phone_number) { nil }

        run_test!
      end

      response '200', 'Success - Search by name' do
        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Bob', phone_number: '0987654321', cash_balance: 200)
        end

        let(:name) { 'Allen' }
        let(:phone_number) { nil }

        run_test!
      end

      response '200', 'Success - Search by phone_number' do
        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Bob', phone_number: '0987654321', cash_balance: 200)
        end

        let(:name) { nil }
        let(:phone_number) { '0912345678' }

        run_test!
      end

      response '200', 'Success - Search by name and phone_number' do
        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Allen', phone_number: '0999999999', cash_balance: 300)
        end

        let(:name) { 'Allen' }
        let(:phone_number) { '0912345678' }

        run_test!
      end
    end
  end

  path '/api/users/{id}' do
    get('Get user by id') do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      let!(:user) { create(:user) } 
      let(:id) { user.id }

      response(200, 'Success') do
        schema type: :object, properties: {
          status: { type: :string },
          data: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              phone_number: { type: :string, nullable: true },
              cash_balance: { type: :number }
            }
          }
        }

        run_test!
      end

      response '404', 'User not found' do
        let(:id) { -1 }
        run_test!
      end
    end
  end

  path '/api/users' do
    post 'Create user' do
      tags 'Users'
      consumes 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          phone_number: { type: :string },
          cash_balance: { type: :number }
        },
        required: ['name', 'phone_number']
      }

      response '200', 'Create success' do
        let(:user) { { name: 'Allen', phone_number: '0912345678', cash_balance: 1000 } }
        run_test!
      end

      response '422', 'Missing phone number' do
        let(:user) { { name: 'Allen', phone_number: '', cash_balance: 1000 } }
        run_test!
      end

      response '422', "Validation failed, possible reasons:\n- Missing phone number\n- Invalid phone number length\n- Phone number already exists" do
        context 'Phone number is missing' do
          let(:user) { { name: 'Allen', phone_number: '', cash_balance: 1000 } }
          run_test!
        end
  
        context 'Phone number already exists' do
          before do
            User.create!(name: 'Allen', phone_number: '0912345678', cash_balance: 1000)
          end
          let(:user) { { name: 'Other', phone_number: '0912345678', cash_balance: 500 } }
          run_test!
        end
  
        context 'Invalid phone number length' do
          let(:user) { { name: 'Allen', phone_number: '0912', cash_balance: 1000 } }
          run_test!
        end
      end
    end
  end

  path '/api/users/{id}/add_balance' do
    post('Add balance to user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'User ID'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number }
        },
        required: ['amount']
      }

      response(200, 'Success') do
        let!(:user) { create(:user, cash_balance: 100) }
        let(:id) { user.id }
        let(:body) { { amount: 200.0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('success')
          expect(json['data']['cash_balance']).to eq(300.0)
        end
      end

      response(404, 'User not found') do
        let(:id) { -1 }
        let(:body) { { amount: 200.0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
        end
      end

      response(400, 'Invalid amount') do
        let!(:user) { create(:user, cash_balance: 100) }
        let(:id) { user.id }
        let(:body) { { amount: -100.0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('fail')
        end
      end
    end
  end
end
