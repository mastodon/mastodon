require 'test_helper'
TestHelper.silence_warnings do
  require 'grape'
end
require 'grape/active_model_serializers'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActiveModelSerializers
  class GrapeTest < ActiveSupport::TestCase
    include Rack::Test::Methods
    module Models
      def self.model1
        ARModels::Post.new(id: 1, title: 'Dummy Title', body: 'Lorem Ipsum')
      end

      def self.model2
        ARModels::Post.new(id: 2, title: 'Second Dummy Title', body: 'Second Lorem Ipsum')
      end

      def self.all
        @all ||=
          begin
            model1.save!
            model2.save!
            ARModels::Post.all
          end
      end

      def self.reset_all
        ARModels::Post.delete_all
        @all = nil
      end

      def self.collection_per
        2
      end

      def self.collection
        @collection ||=
          begin
            Kaminari.paginate_array(
              [
                Profile.new(id: 1, name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
                Profile.new(id: 2, name: 'Name 2', description: 'Description 2', comments: 'Comments 2'),
                Profile.new(id: 3, name: 'Name 3', description: 'Description 3', comments: 'Comments 3'),
                Profile.new(id: 4, name: 'Name 4', description: 'Description 4', comments: 'Comments 4'),
                Profile.new(id: 5, name: 'Name 5', description: 'Description 5', comments: 'Comments 5')
              ]
            ).page(1).per(collection_per)
          end
      end
    end

    class GrapeTest < Grape::API
      format :json
      TestHelper.silence_warnings do
        include Grape::ActiveModelSerializers
      end

      def self.resources(*)
        TestHelper.silence_warnings do
          super
        end
      end

      resources :grape do
        get '/render' do
          render Models.model1
        end

        get '/render_with_json_api' do
          post = Models.model1
          render post, meta: { page: 1, total_pages: 2 }, adapter: :json_api
        end

        get '/render_array_with_json_api' do
          posts = Models.all
          render posts, adapter: :json_api
        end

        get '/render_collection_with_json_api' do
          posts = Models.collection
          render posts, adapter: :json_api
        end

        get '/render_with_implicit_formatter' do
          Models.model1
        end

        get '/render_array_with_implicit_formatter' do
          Models.all
        end

        get '/render_collection_with_implicit_formatter' do
          Models.collection
        end
      end
    end

    def app
      Grape::Middleware::Globals.new(GrapeTest.new)
    end

    extend Minitest::Assertions
    def self.run_one_method(*)
      _, stderr = capture_io do
        super
      end
      fail Minitest::Assertion, stderr if stderr !~ /grape/
    end

    def test_formatter_returns_json
      get '/grape/render'

      post = Models.model1
      serializable_resource = serializable(post)

      assert last_response.ok?
      assert_equal serializable_resource.to_json, last_response.body
    end

    def test_render_helper_passes_through_options_correctly
      get '/grape/render_with_json_api'

      post = Models.model1
      serializable_resource = serializable(post, serializer: ARModels::PostSerializer, adapter: :json_api, meta: { page: 1, total_pages: 2 })

      assert last_response.ok?
      assert_equal serializable_resource.to_json, last_response.body
    end

    def test_formatter_handles_arrays
      get '/grape/render_array_with_json_api'

      posts = Models.all
      serializable_resource = serializable(posts, adapter: :json_api)

      assert last_response.ok?
      assert_equal serializable_resource.to_json, last_response.body
    ensure
      Models.reset_all
    end

    def test_formatter_handles_collections
      get '/grape/render_collection_with_json_api'
      assert last_response.ok?

      representation = JSON.parse(last_response.body)
      assert representation.include?('data')
      assert representation['data'].count == Models.collection_per
      assert representation.include?('links')
      assert representation['links'].count > 0
    end

    def test_implicit_formatter
      post = Models.model1
      serializable_resource = serializable(post, adapter: :json_api)

      with_adapter :json_api do
        get '/grape/render_with_implicit_formatter'
      end

      assert last_response.ok?
      assert_equal serializable_resource.to_json, last_response.body
    end

    def test_implicit_formatter_handles_arrays
      posts = Models.all
      serializable_resource = serializable(posts, adapter: :json_api)

      with_adapter :json_api do
        get '/grape/render_array_with_implicit_formatter'
      end

      assert last_response.ok?
      assert_equal serializable_resource.to_json, last_response.body
    ensure
      Models.reset_all
    end

    def test_implicit_formatter_handles_collections
      with_adapter :json_api do
        get '/grape/render_collection_with_implicit_formatter'
      end

      representation = JSON.parse(last_response.body)
      assert last_response.ok?
      assert representation.include?('data')
      assert representation['data'].count == Models.collection_per
      assert representation.include?('links')
      assert representation['links'].count > 0
    end
  end
end
