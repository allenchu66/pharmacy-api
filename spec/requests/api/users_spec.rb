require 'swagger_helper'

RSpec.describe 'api/users', type: :request do
  path '/api/users' do
    get '取得所有使用者 (支援搜尋 name / phone_number)' do
      tags 'Users'
      produces 'application/json'

      parameter name: :name, in: :query, type: :string, description: '使用者名稱關鍵字'
      parameter name: :phone_number, in: :query, type: :string, description: '使用者電話號碼'

      response '200', '成功 - 無條件' do
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

      response '200', '成功 - 搜尋名稱 name' do
        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Bob', phone_number: '0987654321', cash_balance: 200)
        end

        let(:name) { 'Allen' }
        let(:phone_number) { nil }

        run_test!
      end

      response '200', '成功 - 搜尋電話 phone_number' do
        before do
          User.create(name: 'Allen', phone_number: '0912345678', cash_balance: 100)
          User.create(name: 'Bob', phone_number: '0987654321', cash_balance: 200)
        end

        let(:name) { nil }
        let(:phone_number) { '0912345678' }

        run_test!
      end

      response '200', '成功 - 同時搜尋 name + phone_number' do
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
    get('取得單一使用者') do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      let!(:user) { create(:user) } 
      let(:id) { user.id }

      response(200, '成功') do
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

        response '404', '使用者不存在' do
          let(:id) { -1 }
          run_test!
        end
      end
    end
  end

  path '/api/users' do
    post '新增用戶' do
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

      response '200', '新增成功' do
        let(:user) { { name: 'Allen', phone_number: '0912345678', cash_balance: 1000 } }
        run_test!
      end

      response '422', '手機沒填' do
       
      end

      response '422', "發生錯誤，可能包含：\n- 手機未填\n- 手機長度不正確\n- 手機已存在" do
        context '手機沒填' do
          let(:user) { { name: 'Allen', phone_number: '', cash_balance: 1000 } }
          run_test!
        end
  
        context '手機重複' do
          before do
            User.create!(name: 'Allen', phone_number: '0912345678', cash_balance: 1000)
          end
          let(:user) { { name: 'Other', phone_number: '0912345678', cash_balance: 500 } }
          run_test!
        end
  
        context '手機長度不正確' do
          let(:user) { { name: 'Allen', phone_number: '0912', cash_balance: 1000 } }
          run_test!
        end
      end
    end
  end

end