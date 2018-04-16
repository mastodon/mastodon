# Execute this test in isolation
require 'support/isolated_unit'
require 'minitest/mock'

class SerializationContextTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  class WithRails < SerializationContextTest
    def create_request
      request = ActionDispatch::Request.new({})
      def request.original_url
        'http://example.com/articles?page=2'
      end

      def request.query_parameters
        { 'page' => 2 }
      end
      request
    end

    setup do
      require 'rails'
      require 'active_model_serializers'
      make_basic_app
      @context = ActiveModelSerializers::SerializationContext.new(create_request)
    end

    test 'create context with request url and query parameters' do
      assert_equal @context.request_url, 'http://example.com/articles'
      assert_equal @context.query_parameters, 'page' => 2
    end

    test 'url_helpers is set up for Rails url_helpers' do
      assert_equal Module, ActiveModelSerializers::SerializationContext.url_helpers.class
      assert ActiveModelSerializers::SerializationContext.url_helpers.respond_to? :url_for
    end

    test 'default_url_options returns Rails.application.routes.default_url_options' do
      assert_equal Rails.application.routes.default_url_options,
        ActiveModelSerializers::SerializationContext.default_url_options
    end
  end

  class WithoutRails < SerializationContextTest
    def create_request
      {
        request_url: 'http://example.com/articles',
        query_parameters: { 'page' => 2 }
      }
    end

    setup do
      require 'active_model_serializers/serialization_context'
      @context = ActiveModelSerializers::SerializationContext.new(create_request)
    end

    test 'create context with request url and query parameters' do
      assert_equal @context.request_url, 'http://example.com/articles'
      assert_equal @context.query_parameters, 'page' => 2
    end

    test 'url_helpers is a module when Rails is not present' do
      assert_equal Module, ActiveModelSerializers::SerializationContext.url_helpers.class
      refute ActiveModelSerializers::SerializationContext.url_helpers.respond_to? :url_for
    end

    test 'default_url_options return a Hash' do
      assert Hash, ActiveModelSerializers::SerializationContext.default_url_options.class
    end
  end
end
