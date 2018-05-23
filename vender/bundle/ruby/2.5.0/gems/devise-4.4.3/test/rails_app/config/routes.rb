# frozen_string_literal: true

Rails.application.routes.draw do
  # Resources for testing
  resources :users, only: [:index] do
    member do
      get :expire
      get :accept
      get :edit_form
      put :update_form
    end

    authenticate do
      post :exhibit, on: :member
    end
  end

  resources :admins, only: [:index]

  # Users scope
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_for :user_on_main_apps,
    class_name: 'UserOnMainApp',
    router_name: :main_app,
    module: :devise

  devise_for :user_on_engines,
    class_name: 'UserOnEngine',
    router_name: :fake_engine,
    module: :devise

  devise_for :user_without_email,
    class_name: 'UserWithoutEmail',
    router_name: :main_app,
    module: :devise

  as :user do
    get "/as/sign_in", to: "devise/sessions#new"
  end

  get "/sign_in", to: "devise/sessions#new"

  # Routes for custom controller testing
  devise_for :user, only: [:registrations], controllers: { registrations: "custom/registrations" }, as: :custom, path: :custom

  # Admin scope
  devise_for :admin, path: "admin_area", controllers: { sessions: :"admins/sessions" }, skip: :passwords

  get "/admin_area/home", to: "admins#index", as: :admin_root
  get "/anywhere", to: "foo#bar", as: :new_admin_password

  authenticate(:admin) do
    get "/private", to: "home#private", as: :private
  end

  authenticate(:admin, lambda { |admin| admin.active? }) do
    get "/private/active", to: "home#private", as: :private_active
  end

  authenticated :admin do
    get "/dashboard", to: "home#admin_dashboard"
  end

  authenticated :admin, lambda { |admin| admin.active? } do
    get "/dashboard/active", to: "home#admin_dashboard"
  end

  authenticated do
    get "/dashboard", to: "home#user_dashboard"
  end

  unauthenticated do
    get "/join", to: "home#join"
  end

  # Routes for constraints testing
  devise_for :headquarters_admin, class_name: "Admin", path: "headquarters", constraints: {host: /192\.168\.1\.\d\d\d/}

  constraints(host: /192\.168\.1\.\d\d\d/) do
    devise_for :homebase_admin, class_name: "Admin", path: "homebase"
  end

  scope(subdomain: 'sub') do
    devise_for :subdomain_users, class_name: "User", only: [:sessions]
  end

  devise_for :skip_admin, class_name: "Admin", skip: :all

  # Routes for format=false testing
  devise_for :htmlonly_admin, class_name: "Admin", skip: [:confirmations, :unlocks], path: "htmlonly_admin", format: false, skip_helpers: [:confirmations, :unlocks]
  devise_for :htmlonly_users, class_name: "User", only: [:confirmations, :unlocks], path: "htmlonly_users", format: false, skip_helpers: true

  # Other routes for routing_test.rb
  devise_for :reader, class_name: "User", only: :passwords

  scope host: "sub.example.com" do
    devise_for :sub_admin, class_name: "Admin"
  end

  namespace :publisher, path_names: { sign_in: "i_dont_care", sign_out: "get_out" } do
    devise_for :accounts, class_name: "Admin", path_names: { sign_in: "get_in" }
  end

  scope ":locale", module: :invalid do
    devise_for :accounts, singular: "manager", class_name: "Admin",
      path_names: {
        sign_in: "login", sign_out: "logout",
        password: "secret", confirmation: "verification",
        unlock: "unblock", sign_up: "register",
        registration: "management",
        cancel: "giveup", edit: "edit/profile"
      }, failure_app: lambda { |env| [404, {"Content-Type" => "text/plain"}, ["Oops, not found"]] }, module: :devise
  end

  namespace :sign_out_via, module: "devise" do
    devise_for :deletes, sign_out_via: :delete, class_name: "Admin"
    devise_for :posts, sign_out_via: :post, class_name: "Admin"
    devise_for :gets, sign_out_via: :get, class_name: "Admin"
    devise_for :delete_or_posts, sign_out_via: [:delete, :post], class_name: "Admin"
  end

  get "/set", to: "home#set"
  get "/unauthenticated", to: "home#unauthenticated"
  get "/custom_strategy/new"

  root to: "home#index", via: [:get, :post]
end
