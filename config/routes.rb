Rails.application.routes.draw do

  # Admin namespace
  namespace :admin do
    resources :reports,    only: [:index]
    resources :categories, only: [:index, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
  resources :support_requests, only: %i[ index update ]

  # Users
  resources :users do
    collection do
      get :orders
      get :line_items
    end
  end

  # Aliases
  get "/my-orders", to: "users#orders",     as: :my_orders
  get "/my-items",  to: "users#line_items", as: :my_items

  # Categories
  resources :categories do
    resources :sub_categories, shallow: true

    # /categories/:id/books — integer id only
    get "books", to: "products#index", as: :books,
        constraints: { id: /\d+/ }
  end

  # Non-integer :id → redirect to home (routing only, no controller)
  get "categories/:id/books", to: redirect("/")

  # Products as /books
  resources :products, path: "books"

  # Auth
  resource  :session
  resources :passwords, param: :token

  # Locale scope
  scope "(:locale)" do
    resources :orders
    resources :line_items
    resources :carts
    root "store#index", as: "store_index", via: :all
  end

  # Firefox: block all non-root pages
  match "*path", via: :all,
        constraints: ->(req) { req.user_agent.to_s.include?("Firefox") },
        to: proc { [404, {}, []] }

end
