Rails.application.routes.draw do
  namespace :api do
    resources :pharmacies, only: [:index, :show] do
      resources :masks, only: [:index] do
        collection do
          get :filter  # 對應 filter action
        end
      end
    end
  end
end
