# frozen_string_literal: true

require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/slice"

module Devise
  module RouteSet
    def finalize!
      result = super
      @devise_finalized ||= begin
        if Devise.router_name.nil? && defined?(@devise_finalized) && self != Rails.application.try(:routes)
          warn "[DEVISE] We have detected that you are using devise_for inside engine routes. " \
            "In this case, you probably want to set Devise.router_name = MOUNT_POINT, where "   \
            "MOUNT_POINT is a symbol representing where this engine will be mounted at. For "   \
            "now Devise will default the mount point to :main_app. You can explicitly set it"   \
            " to :main_app as well in case you want to keep the current behavior."
        end

        Devise.configure_warden!
        Devise.regenerate_helpers!
        true
      end
      result
    end
  end
end

module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create filters and helpers.
    prepend Devise::RouteSet
  end

  class Mapper
    # Includes devise_for method for routes. This method is responsible to
    # generate all needed routes for devise, based on what modules you have
    # defined in your model.
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use authenticatable,
    # confirmable and recoverable modules. After creating this inside your routes:
    #
    #   devise_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Session routes for Authenticatable (default)
    #       new_user_session GET    /users/sign_in                    {controller:"devise/sessions", action:"new"}
    #           user_session POST   /users/sign_in                    {controller:"devise/sessions", action:"create"}
    #   destroy_user_session DELETE /users/sign_out                   {controller:"devise/sessions", action:"destroy"}
    #
    #  # Password routes for Recoverable, if User model has :recoverable configured
    #      new_user_password GET    /users/password/new(.:format)     {controller:"devise/passwords", action:"new"}
    #     edit_user_password GET    /users/password/edit(.:format)    {controller:"devise/passwords", action:"edit"}
    #          user_password PUT    /users/password(.:format)         {controller:"devise/passwords", action:"update"}
    #                        POST   /users/password(.:format)         {controller:"devise/passwords", action:"create"}
    #
    #  # Confirmation routes for Confirmable, if User model has :confirmable configured
    #  new_user_confirmation GET    /users/confirmation/new(.:format) {controller:"devise/confirmations", action:"new"}
    #      user_confirmation GET    /users/confirmation(.:format)     {controller:"devise/confirmations", action:"show"}
    #                        POST   /users/confirmation(.:format)     {controller:"devise/confirmations", action:"create"}
    #
    # ==== Routes integration
    #
    # +devise_for+ is meant to play nicely with other routes methods. For example,
    # by calling +devise_for+ inside a namespace, it automatically nests your devise
    # controllers:
    #
    #     namespace :publisher do
    #       devise_for :account
    #     end
    #
    # The snippet above will use publisher/sessions controller instead of devise/sessions
    # controller. You can revert this change or configure it directly by passing the :module
    # option described below to +devise_for+.
    #
    # Also note that when you use a namespace it will affect all the helpers and methods
    # for controllers and views. For example, using the above setup you'll end with
    # following methods: current_publisher_account, authenticate_publisher_account!,
    # publisher_account_signed_in, etc.
    #
    # The only aspect not affect by the router configuration is the model name. The
    # model name can be explicitly set via the :class_name option.
    #
    # ==== Options
    #
    # You can configure your routes with some options:
    #
    #  * class_name: set up a different class to be looked up by devise, if it cannot be
    #    properly found by the route name.
    #
    #      devise_for :users, class_name: 'Account'
    #
    #  * path: allows you to set up path name that will be used, as rails routes does.
    #    The following route configuration would set up your route as /accounts instead of /users:
    #
    #      devise_for :users, path: 'accounts'
    #
    #  * singular: set up the singular name for the given resource. This is used as the helper methods
    #    names in controller ("authenticate_#{singular}!", "#{singular}_signed_in?", "current_#{singular}"
    #    and "#{singular}_session"), as the scope name in routes and as the scope given to warden.
    #
    #      devise_for :admins, singular: :manager
    #
    #      devise_scope :manager do
    #        ...
    #      end
    #
    #      class ManagerController < ApplicationController
    #        before_action authenticate_manager!
    #
    #        def show
    #          @manager = current_manager
    #          ...
    #        end
    #      end
    #
    #  * path_names: configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #    :password, :confirmation, :unlock.
    #
    #      devise_for :users, path_names: {
    #        sign_in: 'login', sign_out: 'logout',
    #        password: 'secret', confirmation: 'verification',
    #        registration: 'register', edit: 'edit/profile'
    #      }
    #
    #  * controllers: the controller which should be used. All routes by default points to Devise controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #      devise_for :users, controllers: { sessions: "users/sessions" }
    #
    #  * failure_app: a rack app which is invoked whenever there is a failure. Strings representing a given
    #    are also allowed as parameter.
    #
    #  * sign_out_via: the HTTP method(s) accepted for the :sign_out action (default: :get),
    #    if you wish to restrict this to accept only :post or :delete requests you should do:
    #
    #      devise_for :users, sign_out_via: [:post, :delete]
    #
    #    You need to make sure that your sign_out controls trigger a request with a matching HTTP method.
    #
    #  * module: the namespace to find controllers (default: "devise", thus
    #    accessing devise/sessions, devise/registrations, and so on). If you want
    #    to namespace all at once, use module:
    #
    #      devise_for :users, module: "users"
    #
    #  * skip: tell which controller you want to skip routes from being created.
    #    It accepts :all as an option, meaning it will not generate any route at all:
    #
    #      devise_for :users, skip: :sessions
    #
    #  * only: the opposite of :skip, tell which controllers only to generate routes to:
    #
    #      devise_for :users, only: :sessions
    #
    #  * skip_helpers: skip generating Devise url helpers like new_session_path(@user).
    #    This is useful to avoid conflicts with previous routes and is false by default.
    #    It accepts true as option, meaning it will skip all the helpers for the controllers
    #    given in :skip but it also accepts specific helpers to be skipped:
    #
    #      devise_for :users, skip: [:registrations, :confirmations], skip_helpers: true
    #      devise_for :users, skip_helpers: [:registrations, :confirmations]
    #
    #  * format: include "(.:format)" in the generated routes? true by default, set to false to disable:
    #
    #      devise_for :users, format: false
    #
    #  * constraints: works the same as Rails' constraints
    #
    #  * defaults: works the same as Rails' defaults
    #
    #  * router_name: allows application level router name to be overwritten for the current scope
    #
    # ==== Scoping
    #
    # Following Rails 3 routes DSL, you can nest devise_for calls inside a scope:
    #
    #   scope "/my" do
    #     devise_for :users
    #   end
    #
    # However, since Devise uses the request path to retrieve the current user,
    # this has one caveat: If you are using a dynamic segment, like so ...
    #
    #   scope ":locale" do
    #     devise_for :users
    #   end
    #
    # you are required to configure default_url_options in your
    # ApplicationController class, so Devise can pick it:
    #
    #   class ApplicationController < ActionController::Base
    #     def self.default_url_options
    #       { locale: I18n.locale }
    #     end
    #   end
    #
    # ==== Adding custom actions to override controllers
    #
    # You can pass a block to devise_for that will add any routes defined in the block to Devise's
    # list of known actions.  This is important if you add a custom action to a controller that
    # overrides an out of the box Devise controller.
    # For example:
    #
    #    class RegistrationsController < Devise::RegistrationsController
    #      def update
    #         # do something different here
    #      end
    #
    #      def deactivate
    #        # not a standard action
    #        # deactivate code here
    #      end
    #    end
    #
    # In order to get Devise to recognize the deactivate action, your devise_scope entry should look like this:
    #
    #     devise_scope :owner do
    #       post "deactivate", to: "registrations#deactivate", as: "deactivate_registration"
    #     end
    #
    def devise_for(*resources)
      @devise_finalized = false
      raise_no_secret_key unless Devise.secret_key
      options = resources.extract_options!

      options[:as]          ||= @scope[:as]     if @scope[:as].present?
      options[:module]      ||= @scope[:module] if @scope[:module].present?
      options[:path_prefix] ||= @scope[:path]   if @scope[:path].present?
      options[:path_names]    = (@scope[:path_names] || {}).merge(options[:path_names] || {})
      options[:constraints]   = (@scope[:constraints] || {}).merge(options[:constraints] || {})
      options[:defaults]      = (@scope[:defaults] || {}).merge(options[:defaults] || {})
      options[:options]       = @scope[:options] || {}
      options[:options][:format] = false if options[:format] == false

      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = Devise.add_mapping(resource, options)

        begin
          raise_no_devise_method_error!(mapping.class_name) unless mapping.to.respond_to?(:devise)
        rescue NameError => e
          raise unless mapping.class_name == resource.to_s.classify
          warn "[WARNING] You provided devise_for #{resource.inspect} but there is " \
            "no model #{mapping.class_name} defined in your application"
          next
        rescue NoMethodError => e
          raise unless e.message.include?("undefined method `devise'")
          raise_no_devise_method_error!(mapping.class_name)
        end

        if options[:controllers] && options[:controllers][:omniauth_callbacks]
          unless mapping.omniauthable?
            raise ArgumentError, "Mapping omniauth_callbacks on a resource that is not omniauthable\n" \
              "Please add `devise :omniauthable` to the `#{mapping.class_name}` model"
          end
        end

        routes = mapping.used_routes

        devise_scope mapping.name do
          with_devise_exclusive_scope mapping.fullpath, mapping.name, options do
            routes.each { |mod| send("devise_#{mod}", mapping, mapping.controllers) }
          end
        end
      end
    end

    # Allow you to add authentication request from the router.
    # Takes an optional scope and block to provide constraints
    # on the model instance itself.
    #
    #   authenticate do
    #     resources :post
    #   end
    #
    #   authenticate(:admin) do
    #     resources :users
    #   end
    #
    #   authenticate :user, lambda {|u| u.role == "admin"} do
    #     root to: "admin/dashboard#show", as: :user_root
    #   end
    #
    def authenticate(scope=nil, block=nil)
      constraints_for(:authenticate!, scope, block) do
        yield
      end
    end

    # Allow you to route based on whether a scope is authenticated. You
    # can optionally specify which scope and a block. The block accepts
    # a model and allows extra constraints to be done on the instance.
    #
    #   authenticated :admin do
    #     root to: 'admin/dashboard#show', as: :admin_root
    #   end
    #
    #   authenticated do
    #     root to: 'dashboard#show', as: :authenticated_root
    #   end
    #
    #   authenticated :user, lambda {|u| u.role == "admin"} do
    #     root to: "admin/dashboard#show", as: :user_root
    #   end
    #
    #   root to: 'landing#show'
    #
    def authenticated(scope=nil, block=nil)
      constraints_for(:authenticate?, scope, block) do
        yield
      end
    end

    # Allow you to route based on whether a scope is *not* authenticated.
    # You can optionally specify which scope.
    #
    #   unauthenticated do
    #     as :user do
    #       root to: 'devise/registrations#new'
    #     end
    #   end
    #
    #   root to: 'dashboard#show'
    #
    def unauthenticated(scope=nil)
      constraint = lambda do |request|
        not request.env["warden"].authenticate? scope: scope
      end

      constraints(constraint) do
        yield
      end
    end

    # Sets the devise scope to be used in the controller. If you have custom routes,
    # you are required to call this method (also aliased as :as) in order to specify
    # to which controller it is targeted.
    #
    #   as :user do
    #     get "sign_in", to: "devise/sessions#new"
    #   end
    #
    # Notice you cannot have two scopes mapping to the same URL. And remember, if
    # you try to access a devise controller without specifying a scope, it will
    # raise ActionNotFound error.
    #
    # Also be aware of that 'devise_scope' and 'as' use the singular form of the
    # noun where other devise route commands expect the plural form. This would be a
    # good and working example.
    #
    #  devise_scope :user do
    #    get "/some/route" => "some_devise_controller"
    #  end
    #  devise_for :users
    #
    # Notice and be aware of the differences above between :user and :users
    def devise_scope(scope)
      constraint = lambda do |request|
        request.env["devise.mapping"] = Devise.mappings[scope]
        true
      end

      constraints(constraint) do
        yield
      end
    end
    alias :as :devise_scope

    protected

      def devise_session(mapping, controllers) #:nodoc:
        resource :session, only: [], controller: controllers[:sessions], path: "" do
          get   :new,     path: mapping.path_names[:sign_in],  as: "new"
          post  :create,  path: mapping.path_names[:sign_in]
          match :destroy, path: mapping.path_names[:sign_out], as: "destroy", via: mapping.sign_out_via
        end
      end

      def devise_password(mapping, controllers) #:nodoc:
        resource :password, only: [:new, :create, :edit, :update],
          path: mapping.path_names[:password], controller: controllers[:passwords]
      end

      def devise_confirmation(mapping, controllers) #:nodoc:
        resource :confirmation, only: [:new, :create, :show],
          path: mapping.path_names[:confirmation], controller: controllers[:confirmations]
      end

      def devise_unlock(mapping, controllers) #:nodoc:
        if mapping.to.unlock_strategy_enabled?(:email)
          resource :unlock, only: [:new, :create, :show],
            path: mapping.path_names[:unlock], controller: controllers[:unlocks]
        end
      end

      def devise_registration(mapping, controllers) #:nodoc:
        path_names = {
          new: mapping.path_names[:sign_up],
          edit: mapping.path_names[:edit],
          cancel: mapping.path_names[:cancel]
        }

        options = {
          only: [:new, :create, :edit, :update, :destroy],
          path: mapping.path_names[:registration],
          path_names: path_names,
          controller: controllers[:registrations]
        }

        resource :registration, options do
          get :cancel
        end
      end

      def devise_omniauth_callback(mapping, controllers) #:nodoc:
        if mapping.fullpath =~ /:[a-zA-Z_]/
          raise <<-ERROR
Devise does not support scoping OmniAuth callbacks under a dynamic segment
and you have set #{mapping.fullpath.inspect}. You can work around by passing
`skip: :omniauth_callbacks` to the `devise_for` call and extract omniauth
options to another `devise_for` call outside the scope. Here is an example:

    devise_for :users, only: :omniauth_callbacks, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

    scope '/(:locale)', locale: /ru|en/ do
      devise_for :users, skip: :omniauth_callbacks
    end
ERROR
        end
        current_scope = @scope.dup
        if @scope.respond_to? :new
          @scope = @scope.new path: nil
        else
          @scope[:path] = nil
        end
        path_prefix = Devise.omniauth_path_prefix || "/#{mapping.fullpath}/auth".squeeze("/")

        set_omniauth_path_prefix!(path_prefix)

        mapping.to.omniauth_providers.each do |provider|
          match "#{path_prefix}/#{provider}",
            to: "#{controllers[:omniauth_callbacks]}#passthru",
            as: "#{provider}_omniauth_authorize",
            via: [:get, :post]

          match "#{path_prefix}/#{provider}/callback",
            to: "#{controllers[:omniauth_callbacks]}##{provider}",
            as: "#{provider}_omniauth_callback",
            via: [:get, :post]
        end
      ensure
        @scope = current_scope
      end

      def with_devise_exclusive_scope(new_path, new_as, options) #:nodoc:
        current_scope = @scope.dup

        exclusive = { as: new_as, path: new_path, module: nil }
        exclusive.merge!(options.slice(:constraints, :defaults, :options))

        if @scope.respond_to? :new
          @scope = @scope.new exclusive
        else
          exclusive.each_pair { |key, value| @scope[key] = value }
        end
        yield
      ensure
        @scope = current_scope
      end

      def constraints_for(method_to_apply, scope=nil, block=nil)
        constraint = lambda do |request|
          request.env['warden'].send(method_to_apply, scope: scope) &&
            (block.nil? || block.call(request.env["warden"].user(scope)))
        end

        constraints(constraint) do
          yield
        end
      end

      def set_omniauth_path_prefix!(path_prefix) #:nodoc:
        if ::OmniAuth.config.path_prefix && ::OmniAuth.config.path_prefix != path_prefix
          raise "Wrong OmniAuth configuration. If you are getting this exception, it means that either:\n\n" \
            "1) You are manually setting OmniAuth.config.path_prefix and it doesn't match the Devise one\n" \
            "2) You are setting :omniauthable in more than one model\n" \
            "3) You changed your Devise routes/OmniAuth setting and haven't restarted your server"
        else
          ::OmniAuth.config.path_prefix = path_prefix
        end
      end

      def raise_no_secret_key #:nodoc:
        raise <<-ERROR
Devise.secret_key was not set. Please add the following to your Devise initializer:

  config.secret_key = '#{SecureRandom.hex(64)}'

Please ensure you restarted your application after installing Devise or setting the key.
ERROR
      end

      def raise_no_devise_method_error!(klass) #:nodoc:
        raise "#{klass} does not respond to 'devise' method. This usually means you haven't " \
          "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'devise/orm/YOUR_ORM' " \
          "inside 'config/initializers/devise.rb' or before your application definition in 'config/application.rb'"
      end
  end
end
