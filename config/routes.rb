Rails.application.routes.draw do
  namespace :api do
    resources :pharmacies, only: [:index, :show] do
      resources :masks, only: [:index, :show] do
        collection do
          get :filter
        end
      end

      collection do
        get :search
        get :open
      end
    end

    resources :masks, only: [] do
      collection do
        get :search
        get :all
      end
    
      member do
        get :detail
      end
    end

    resources :orders, only: [:create, :index]

    resources :users, only: [:index, :show]
  end
end
