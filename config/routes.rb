Rails.application.routes.draw do
  devise_for :admins

  namespace :api do
    get "facts/random", to: "facts#random"
  end

  namespace :admin do
    resources :facts
  end

  root "admin/facts#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
