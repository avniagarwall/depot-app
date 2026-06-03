Rails.application.routes.draw do
  
  root "store#index"
  get "store", to: "store#index", as: :store_index
  get "store/:id", to: "store#show", as: :store_product

  firefox_only = ->(req) { req.user_agent&.include?("Firefox") }
  not_firefox  = ->(req) { !req.user_agent&.include?("Firefox") }

  constraints(not_firefox) do
    get "up", to: "rails/health#show", as: :rails_health_check

    get "questions", to: "questions#index"
    get "news",      to: "news#index"
    get "contact",   to: "contact#index"

    namespace :admin do
      resources :reports,    only: [ :index ]
      resources :categories, only: [ :index ]
      resources :tags,       only: [ :index, :create, :destroy ]
    end

    get "my-orders", to: "users#orders",     as: :my_orders
    get "my-items",  to: "users#line_items", as: :my_items

    resources :users

    resources :products

    get "categories/:id/products", to: "products#index",
        constraints: { id: /\d+/ },
        as: :category_products

    get "categories/:id/products", to: redirect("/")

    resources :categories, only: [ :index, :show ]

    resource  :session
    resources :passwords, param: :token

    resources :support_requests, only: %i[ index update ]

    scope "(:locale)" do
      resources :orders
      resources :line_items
      resources :carts
    end
  end

  constraints(firefox_only) do
    root "store#index", as: :firefox_root
  end
end