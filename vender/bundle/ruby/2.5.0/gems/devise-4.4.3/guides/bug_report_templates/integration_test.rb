# frozen_string_literal: true

begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'rails', '~> 4.2.0'
  gem 'devise', '~> 4.0'
  gem 'sqlite3'
  gem 'byebug'
end

require 'rack/test'
require 'action_controller/railtie'
require 'active_record'
require 'devise/rails/routes'
require 'devise/rails/warden_compat'

ActiveRecord::Base.establish_connection( adapter: :sqlite3, database:  ':memory:')

class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email,              null: false
      t.string :encrypted_password, null: true
      t.timestamps null: false
    end

  end
end

Devise.setup do |config|
  require 'devise/orm/active_record'
  config.secret_key = 'secret_key_base'
end

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'
  config.eager_load = false

  config.middleware.use Warden::Manager do |config|
    Devise.warden_config = config
  end

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

end

Rails.application.initialize!

DeviseCreateUsers.migrate(:up)

class User < ActiveRecord::Base
  devise :database_authenticatable
end

Rails.application.routes.draw do
  devise_for :users

  get '/' => 'test#index'
end

class ApplicationController < ActionController::Base
end

class TestController < ApplicationController
  include Rails.application.routes.url_helpers

  before_filter :authenticate_user!

  def index
    render plain: 'Home'
  end
end

require 'minitest/autorun'

class BugTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods
  include Warden::Test::Helpers

  def test_returns_success
    Warden.test_mode!

    login_as User.create!(email: 'test@test.com', password: 'test123456', password_confirmation: 'test123456')

    get '/'
    assert last_response.ok?
  end

  private

  def app
    Rails.application
  end
end
