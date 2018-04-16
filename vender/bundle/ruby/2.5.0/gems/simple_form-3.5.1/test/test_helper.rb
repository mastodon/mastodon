# frozen_string_literal: true
require 'bundler/setup'

require 'minitest/autorun'

require 'active_model'
require 'action_controller'
require 'action_view'
ActionView::RoutingUrlFor.send(:include, ActionDispatch::Routing::UrlFor)

require 'action_view/template'

require 'action_view/test_case'

module Rails
  def self.env
    ActiveSupport::StringInquirer.new("test")
  end
end

$:.unshift File.expand_path("../../lib", __FILE__)
require 'simple_form'

require "rails/generators/test_case"
require 'generators/simple_form/install_generator'

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each do |file|
  require file unless file.end_with?('discovery_inputs.rb')
end
I18n.default_locale = :en

require 'country_select'

if defined?(HTMLSelector::NO_STRIP)
  HTMLSelector::NO_STRIP << "label"
else
  ActionDispatch::Assertions::NO_STRIP << "label"
end

if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end

class ActionView::TestCase
  include MiscHelpers
  include SimpleForm::ActionViewExtensions::FormHelper

  setup :set_controller
  setup :setup_users

  def set_controller
    @controller = MockController.new
  end

  def setup_users(extra_attributes = {})
    @user = User.build(extra_attributes)
    @decorated_user = Decorator.new(@user)

    @validating_user = ValidatingUser.build({
      name: 'Tester McTesterson',
      description: 'A test user of the most distinguised caliber',
      home_picture: 'Home picture',
      age: 19,
      amount: 15,
      attempts: 1,
      company: [1]
    }.merge!(extra_attributes))

    @other_validating_user = OtherValidatingUser.build({
      age: 19,
      company: 1
    }.merge!(extra_attributes))
  end

  def protect_against_forgery?
    false
  end

  def user_path(*args)
    '/users'
  end

  def company_user_path(*args)
    '/company/users'
  end

  alias :users_path :user_path
  alias :super_user_path :user_path
  alias :validating_user_path :user_path
  alias :validating_users_path :user_path
  alias :other_validating_user_path :user_path
end
