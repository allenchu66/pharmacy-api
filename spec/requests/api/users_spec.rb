require 'swagger_helper'

RSpec.describe 'api/users', type: :request do
  path '/api/users/{id}' do
    get('取得單一使用者') do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'User ID'

      let!(:user) { create(:user) }  # <<== 重點
      let(:id) { user.id }

      response(200, '成功') do
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
    end
  end
end