Rails.application.routes.draw do
  devise_for :admins

  namespace :api do
    get "facts/random", to: "facts#random"
    get "facts/next", to: "facts#next"
  end

  namespace :admin do
    resources :facts
    resources :clients, only: %i[index show new create destroy update] do
      member do
        post :reset
      end
    end
    get  "setup",             to: "setup#show",           as: :setup
    post "setup/imports",     to: "setup#create_import",  as: :setup_imports
    get  "setup/imports/:id", to: "setup#import_status",  as: :setup_import
  end

  root "admin/facts#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
