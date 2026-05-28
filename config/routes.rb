Rails.application.routes.draw do

  firefox_only = ->(req) { req.user_agent&.include?("Firefox") }
  not_firefox  = ->(req) { !req.user_agent&.include?("Firefox") }

  constraints(not_firefox) do
    get "up", to: "rails/health#show", as: :rails_health_check

    namespace :admin do
      resources :reports,    only: [ :index ]
      resources :categories, only: [ :index ]
    end

    get "my-orders", to: "users#orders",     as: :my_orders
    get "my-items",  to: "users#line_items", as: :my_items

    resources :users

    resources :books, controller: "products"

    get "categories/:id/books", to: "products#index",
        constraints: { id: /\d+/ },
        as: :category_books

    get "categories/:id/books", to: redirect("/")

    resources :categories, only: [ :index, :show ]

    resource  :session
    resources :passwords, param: :token

    resources :support_requests, only: %i[ index update ]

    scope "(:locale)" do
      resources :orders
      resources :line_items
      resources :carts
      root "store#index"
    end
  end

  constraints(firefox_only) do
    root "store#index", as: :firefox_root
  end
end