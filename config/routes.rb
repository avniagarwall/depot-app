Rails.application.routes.draw do
  get "admin" => "admin#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :support_requests, only: %i[ index update ]

  resources :users do
    collection do
      get :orders
      get :line_items
    end
  end
  
  resources :products
  resource :session
  resources :passwords, param: :token

  scope "(:locale)" do
    resources :orders
    resources :line_items
    resources :carts
    root "store#index", as: "store_index", via: :all
  end
end