require 'support/isolated_unit'
require 'minitest/mock'
require 'action_dispatch'
require 'action_controller'

class JsonApiRendererTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::Isolation

  class TestController < ActionController::Base
    class << self
      attr_accessor :last_request_parameters
    end

    def render_with_jsonapi_renderer
      permitted_params = params.permit(data: [:id, :type, attributes: [:name]])
      permitted_params = permitted_params.to_h.with_indifferent_access
      attributes =
        if permitted_params[:data]
          permitted_params[:data][:attributes].merge(id: permitted_params[:data][:id])
        else
          # Rails returns empty params when no mime type can be negotiated.
          # (Until https://github.com/rails/rails/pull/26632 is reviewed.)
          permitted_params
        end
      author = Author.new(attributes)
      render jsonapi: author
    end

    def parse
      self.class.last_request_parameters = request.request_parameters
      head :ok
    end
  end

  def teardown
    TestController.last_request_parameters = nil
  end

  def assert_parses(expected, actual, headers = {})
    post '/parse', params: actual, headers: headers
    assert_response :ok
    assert_equal(expected, TestController.last_request_parameters)
  end

  def define_author_model_and_serializer
    TestController.const_set(:Author, Class.new(ActiveModelSerializers::Model) do
      attributes :id, :name
    end)
    TestController.const_set(:AuthorSerializer, Class.new(ActiveModel::Serializer) do
      type 'users'
      attribute :id
      attribute :name
    end)
  end

  class WithoutRenderer < JsonApiRendererTest
    setup do
      require 'rails'
      require 'active_record'
      require 'support/rails5_shims'
      require 'active_model_serializers'
      require 'fixtures/poro'

      make_basic_app

      Rails.application.routes.draw do
        ActiveSupport::Deprecation.silence do
          match ':action', to: TestController, via: [:get, :post]
        end
      end
      define_author_model_and_serializer
    end

    def test_jsonapi_parser_not_registered
      parsers = if Rails::VERSION::MAJOR >= 5
                  ActionDispatch::Request.parameter_parsers
                else
                  ActionDispatch::ParamsParser::DEFAULT_PARSERS
                end
      assert_nil parsers[Mime[:jsonapi]]
    end

    def test_jsonapi_renderer_not_registered
      payload = '{"data": {"attributes": {"name": "Johnny Rico"}, "type": "users", "id": "36c9c04e-86b1-4636-a5b0-8616672d1765"}}'
      headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
      post '/render_with_jsonapi_renderer', params: payload, headers: headers
      assert_equal '', response.body
      assert_equal 500, response.status
      assert_equal ActionView::MissingTemplate, request.env['action_dispatch.exception'].class
    end

    def test_jsonapi_parser
      assert_parses(
        {},
        '',
        'CONTENT_TYPE' => 'application/vnd.api+json'
      )
    end
  end

  class WithRenderer < JsonApiRendererTest
    setup do
      require 'rails'
      require 'active_record'
      require 'support/rails5_shims'
      require 'active_model_serializers'
      require 'fixtures/poro'
      require 'active_model_serializers/register_jsonapi_renderer'

      make_basic_app

      Rails.application.routes.draw do
        ActiveSupport::Deprecation.silence do
          match ':action', to: TestController, via: [:get, :post]
        end
      end
      define_author_model_and_serializer
    end

    def test_jsonapi_parser_registered
      if Rails::VERSION::MAJOR >= 5
        parsers = ActionDispatch::Request.parameter_parsers
        assert_equal Proc, parsers[:jsonapi].class
      else
        parsers = ActionDispatch::ParamsParser::DEFAULT_PARSERS
        assert_equal Proc, parsers[Mime[:jsonapi]].class
      end
    end

    def test_jsonapi_renderer_registered
      expected = {
        'data' => {
          'id' => '36c9c04e-86b1-4636-a5b0-8616672d1765',
          'type' => 'users',
          'attributes' => { 'name' => 'Johnny Rico' }
        }
      }

      payload = '{"data": {"attributes": {"name": "Johnny Rico"}, "type": "users", "id": "36c9c04e-86b1-4636-a5b0-8616672d1765"}}'
      headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
      post '/render_with_jsonapi_renderer', params: payload, headers: headers
      assert_equal expected.to_json, response.body
    end

    def test_jsonapi_parser
      assert_parses(
        {
          'data' => {
            'attributes' => {
              'name' => 'John Doe'
            },
            'type' => 'users',
            'id' => '36c9c04e-86b1-4636-a5b0-8616672d1765'
          }
        },
        '{"data": {"attributes": {"name": "John Doe"}, "type": "users", "id": "36c9c04e-86b1-4636-a5b0-8616672d1765"}}',
        'CONTENT_TYPE' => 'application/vnd.api+json'
      )
    end
  end
end
