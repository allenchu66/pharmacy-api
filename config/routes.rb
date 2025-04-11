Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    resources :pharmacies, only: [:index, :show] do
      resources :masks, only: [:index]
    end  
  end
end


