# frozen_string_literal: true

require 'test_helper'
require 'test_models'

class ActiveRecordTest < ActiveSupport::TestCase
  def include_module?(klass, mod)
    klass.devise_modules.include?(mod) &&
      klass.included_modules.include?(Devise::Models::const_get(mod.to_s.classify))
  end

  def assert_include_modules(klass, *modules)
    modules.each do |mod|
      assert include_module?(klass, mod)
    end

    (Devise::ALL - modules).each do |mod|
      refute include_module?(klass, mod)
    end
  end

  test 'can cherry pick modules' do
    assert_include_modules Admin, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :confirmable
  end

  test 'validations options are not applied too late' do
    validators = WithValidation.validators_on :password
    length = validators.find { |v| v.kind == :length }
    assert_equal 2, length.options[:minimum]
    assert_equal 6, length.options[:maximum]
  end

  test 'validations are applied just once' do
    validators = Several.validators_on :password
    assert_equal 1, validators.select{ |v| v.kind == :length }.length
  end

  test 'chosen modules are inheritable' do
    assert_include_modules Inheritable, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :confirmable
  end

  test 'order of module inclusion' do
    correct_module_order   = [:database_authenticatable, :recoverable, :registerable, :confirmable, :lockable, :timeoutable]
    incorrect_module_order = [:database_authenticatable, :timeoutable, :registerable, :recoverable, :lockable, :confirmable]

    assert_include_modules Admin, *incorrect_module_order

    # get module constants from symbol list
    module_constants = correct_module_order.collect { |mod| Devise::Models::const_get(mod.to_s.classify) }

    # confirm that they adhere to the order in ALL
    # get included modules, filter out the noise, and reverse the order
    assert_equal module_constants, (Admin.included_modules & module_constants).reverse
  end

  test 'raise error on invalid module' do
    assert_raise NameError do
      # Mix valid an invalid modules.
      Configurable.class_eval { devise :database_authenticatable, :doesnotexit }
    end
  end

  test 'set a default value for stretches' do
    assert_equal 15, Configurable.stretches
  end

  test 'set a default value for pepper' do
    assert_equal 'abcdef', Configurable.pepper
  end

  test 'set a default value for allow_unconfirmed_access_for' do
    assert_equal 5.days, Configurable.allow_unconfirmed_access_for
  end

  test 'set a default value for remember_for' do
    assert_equal 7.days, Configurable.remember_for
  end

  test 'set a default value for timeout_in' do
    assert_equal 15.minutes, Configurable.timeout_in
  end

  test 'set a default value for unlock_in' do
    assert_equal 10.days, Configurable.unlock_in
  end

  test 'set null fields on migrations' do
    # Ignore email sending since no email exists.
    klass = Class.new(Admin) do
      def send_devise_notification(*); end
    end

    klass.create!
  end
end

module StubModelFilters
  def stub_filter(name)
    define_singleton_method(name) { |*| nil }
  end
end

class CheckFieldsTest < ActiveSupport::TestCase
  test 'checks if the class respond_to the required fields' do
    Player = Class.new do
      extend Devise::Models
      extend StubModelFilters

      stub_filter :before_validation
      stub_filter :after_update

      devise :database_authenticatable

      attr_accessor :encrypted_password, :email
    end

    assert_nothing_raised do
      Devise::Models.check_fields!(Player)
    end
  end

  test 'raises Devise::Models::MissingAtrribute and shows the missing attribute if the class doesn\'t respond_to one of the attributes' do
    Clown = Class.new do
      extend Devise::Models
      extend StubModelFilters

      stub_filter :before_validation
      stub_filter :after_update

      devise :database_authenticatable

      attr_accessor :encrypted_password
    end

    assert_raise_with_message Devise::Models::MissingAttribute, "The following attribute(s) is (are) missing on your model: email" do
      Devise::Models.check_fields!(Clown)
    end
  end

  test 'raises Devise::Models::MissingAtrribute with all the missing attributes if there is more than one' do
    Magician = Class.new do
      extend Devise::Models
      extend StubModelFilters

      stub_filter :before_validation
      stub_filter :after_update

      devise :database_authenticatable
    end

    assert_raise_with_message Devise::Models::MissingAttribute, "The following attribute(s) is (are) missing on your model: encrypted_password, email" do
      Devise::Models.check_fields!(Magician)
    end
  end
end
