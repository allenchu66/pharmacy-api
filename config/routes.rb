Rails.application.routes.draw do
  namespace :api do
    resources :pharmacies, only: [:index, :show] do
      resources :masks, only: [:index, :show] do
        collection do
          get :filter
        end
      end
    end
  
    resources :masks, only: [] do
      collection do
        get :search
      end
    end
  end
end
