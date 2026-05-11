Rails.application.routes.draw do
  get "contacts/new"
  get "contacts/create"
  get "admin" => "admin#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :support_requests, only: %i[ index update ]

  resources :products do
    resources :reviews, only: [:index, :new, :create, :show, :destroy]
  end

  resources :users
  resources :products
  resource :session
  resources :passwords, param: :token
  resources :contacts, only: [:new, :create]

  scope "(:locale)" do
    resources :orders
    resources :line_items
    resources :carts
    root "store#index", as: "store_index", via: :all

    get "store/:id", to: "store#show", as: "store_product"
  end
end