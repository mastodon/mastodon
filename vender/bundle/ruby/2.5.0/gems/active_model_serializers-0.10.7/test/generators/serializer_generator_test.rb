require 'test_helper'
require 'generators/rails/resource_override'
require 'generators/rails/serializer_generator'

class SerializerGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../../tmp/generators', __FILE__)
  setup :prepare_destination

  tests Rails::Generators::SerializerGenerator
  arguments %w(account name:string description:text business:references)

  def test_generates_a_serializer
    run_generator
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ActiveModel::Serializer/
  end

  def test_generates_a_namespaced_serializer
    run_generator ['admin/account']
    assert_file 'app/serializers/admin/account_serializer.rb', /class Admin::AccountSerializer < ActiveModel::Serializer/
  end

  def test_uses_application_serializer_if_one_exists
    stub_safe_constantize(expected: 'ApplicationSerializer') do
      run_generator
      assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ApplicationSerializer/
    end
  end

  def test_uses_given_parent
    Object.const_set(:ApplicationSerializer, Class.new)
    run_generator ['Account', '--parent=MySerializer']
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < MySerializer/
  ensure
    Object.send :remove_const, :ApplicationSerializer
  end

  def test_generates_attributes_and_associations
    run_generator
    assert_file 'app/serializers/account_serializer.rb' do |serializer|
      assert_match(/^  attributes :id, :name, :description$/, serializer)
      assert_match(/^  has_one :business$/, serializer)
      assert_match(/^end\n*\z/, serializer)
    end
  end

  def test_with_no_attributes_does_not_add_extra_space
    run_generator ['account']
    assert_file 'app/serializers/account_serializer.rb' do |content|
      if RUBY_PLATFORM =~ /mingw/
        assert_no_match(/\r\n\r\nend/, content)
      else
        assert_no_match(/\n\nend/, content)
      end
    end
  end

  private

  def stub_safe_constantize(expected:)
    String.class_eval do
      alias_method :old, :safe_constantize
    end
    String.send(:define_method, :safe_constantize) do
      Class if self == expected
    end

    yield
  ensure
    String.class_eval do
      undef_method :safe_constantize
      alias_method :safe_constantize, :old
      undef_method :old
    end
  end
end
