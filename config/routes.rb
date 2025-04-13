Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/swagger'
  mount Rswag::Ui::Engine => '/api-docs'
  namespace :api do
    resources :pharmacies, only: [:index, :show] do
      resources :masks, only: [:index, :show], controller: 'masks' do
        collection do
          get '/', action: :pharmacy_index
        end
      end
    end

     # 查所有 Mask（含條件搜尋、排序）
    resources :masks, only: [:index, :show]

    resources :pharmacies, only: [] do
      # 查指定藥局的 Mask（支援 keyword / 篩選 / 排序）
      resources :masks, only: [:index, :show]
    end

    resources :pharmacies do
      resources :masks, only: [:index, :show] do
        collection do
          get :filter  # 保留原藥局 filter API
        end
      end
  end

  resources :orders, only: [:create, :index, :show]
  namespace :orders do
    namespace :analytics do
      get :top_users
      get :statistics
    end
  end

    resources :users, only: [:index, :show]
  end
end
