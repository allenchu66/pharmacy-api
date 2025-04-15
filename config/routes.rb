Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/swagger'
  mount Rswag::Ui::Engine => '/api-docs'

  namespace :api do
    # Pharmacies
    resources :pharmacies, only: [:index, :show, :create] do
      # 單一 pharmacy 的 masks
      resources :masks, only: [:index, :show], controller: 'masks' do
        collection do
          get '/', action: :pharmacy_index
          get :filter  # 保留原本的 filter
        end
      end
      # 進貨 API
      resources :mask_purchases, only: [:create]
      #藥局儲值資金
      resource :add_funds, only: [:create], controller: 'pharmacies/add_funds'
      member do
        put :opening_hours  # 對應 /api/pharmacies/:id/opening_hours
      end
      collection do
        get :filter_by_mask_conditions
      end
    end

    # 全部 Mask（支援條件搜尋）
    resources :masks, only: [:index, :show]

    # Orders
    resources :orders, only: [:create, :index, :show]

    namespace :orders do
      namespace :analytics do
        get :top_users
        get :statistics
      end
    end

    # Users
    resources :users, only: [:create, :index, :show] do
      member do
        post :add_balance
      end
    end

    resources :mask_types, only: [:index, :show, :create]
  end
end
