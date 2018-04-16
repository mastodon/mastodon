require 'test_helper'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class ImplicitSerializationTestController < ActionController::Base
        include SerializationTesting
        def render_using_implicit_serializer
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile
        end

        def render_using_default_adapter_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile
        end

        def render_array_using_custom_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: [@profile], root: 'custom_root'
        end

        def render_array_that_is_empty_using_custom_root
          render json: [], root: 'custom_root'
        end

        def render_object_using_custom_root
          @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          render json: @profile, root: 'custom_root'
        end

        def render_array_using_implicit_serializer
          array = [
            Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
            Profile.new(name: 'Name 2', description: 'Description 2', comments: 'Comments 2')
          ]
          render json: array
        end

        def render_array_using_implicit_serializer_and_meta
          @profiles = [
            Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
          ]
          render json: @profiles, meta: { total: 10 }
        end

        def render_array_using_implicit_serializer_and_links
          with_adapter ActiveModelSerializers::Adapter::JsonApi do
            @profiles = [
              Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
            ]

            render json: @profiles, links: { self: 'http://example.com/api/profiles/1' }
          end
        end

        def render_object_with_cache_enabled
          @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @author  = Author.new(id: 1, name: 'Joao Moura.')
          @post    = Post.new(id: 1, title: 'New Post', body: 'Body', comments: [@comment], author: @author)

          generate_cached_serializer(@post)

          @post.title = 'ZOMG a New Post'
          render json: @post
        end

        def render_json_object_without_serializer
          render json: { error: 'Result is Invalid' }
        end

        def render_json_array_object_without_serializer
          render json: [{ error: 'Result is Invalid' }]
        end

        def update_and_render_object_with_cache_enabled
          @post.updated_at = Time.zone.now

          generate_cached_serializer(@post)
          render json: @post
        end

        def render_object_expired_with_cache_enabled
          comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new(id: 1, title: 'New Post', body: 'Body', comments: [comment], author: author)

          generate_cached_serializer(post)

          post.title = 'ZOMG a New Post'

          expires_in = [
            PostSerializer._cache_options[:expires_in],
            CommentSerializer._cache_options[:expires_in]
          ].max + 200

          Timecop.travel(Time.zone.now + expires_in) do
            render json: post
          end
        end

        def render_changed_object_with_cache_enabled
          comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          author = Author.new(id: 1, name: 'Joao Moura.')
          post = Post.new(id: 1, title: 'ZOMG a New Post', body: 'Body', comments: [comment], author: author)

          render json: post
        end

        def render_fragment_changed_object_with_only_cache_enabled
          author = Author.new(id: 1, name: 'Joao Moura.')
          role = Role.new(id: 42, name: 'ZOMG A ROLE', description: 'DESCRIPTION HERE', author: author)

          generate_cached_serializer(role)
          role.name = 'lol'
          role.description = 'HUEHUEBRBR'

          render json: role
        end

        def render_fragment_changed_object_with_except_cache_enabled
          author = Author.new(id: 1, name: 'Joao Moura.')
          bio = Bio.new(id: 42, content: 'ZOMG A ROLE', rating: 5, author: author)

          generate_cached_serializer(bio)
          bio.content = 'lol'
          bio.rating = 0

          render json: bio
        end

        def render_fragment_changed_object_with_relationship
          comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          comment2 = Comment.new(id: 1, body: 'ZOMG AN UPDATED-BUT-NOT-CACHE-EXPIRED COMMENT')
          like = Like.new(id: 1, likeable: comment, time: 3.days.ago)

          generate_cached_serializer(like)
          like.likeable = comment2
          like.time = Time.zone.now.to_s

          render json: like
        end
      end

      tests ImplicitSerializationTestController

      # We just have Null for now, this will change
      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer

        expected = {
          name: 'Name 1',
          description: 'Description 1'
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_using_default_root
        with_adapter :json_api do
          get :render_using_default_adapter_root
        end
        expected = {
          data: {
            id: @controller.instance_variable_get(:@profile).id.to_s,
            type: 'profiles',
            attributes: {
              name: 'Name 1',
              description: 'Description 1'
            }
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_custom_root
        with_adapter :json do
          get :render_array_using_custom_root
        end
        expected = { custom_root: [{ name: 'Name 1', description: 'Description 1' }] }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_that_is_empty_using_custom_root
        with_adapter :json do
          get :render_array_that_is_empty_using_custom_root
        end

        expected = { custom_root: [] }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_object_using_custom_root
        with_adapter :json do
          get :render_object_using_custom_root
        end

        expected = { custom_root: { name: 'Name 1', description: 'Description 1' } }
        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_json_object_without_serializer
        get :render_json_object_without_serializer

        assert_equal 'application/json', @response.content_type
        expected_body = { error: 'Result is Invalid' }
        assert_equal expected_body.to_json, @response.body
      end

      def test_render_json_array_object_without_serializer
        get :render_json_array_object_without_serializer

        assert_equal 'application/json', @response.content_type
        expected_body = [{ error: 'Result is Invalid' }]
        assert_equal expected_body.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer
        get :render_array_using_implicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          {
            name: 'Name 1',
            description: 'Description 1'
          },
          {
            name: 'Name 2',
            description: 'Description 2'
          }
        ]

        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer_and_meta
        with_adapter :json_api do
          get :render_array_using_implicit_serializer_and_meta
        end
        expected = {
          data: [
            {
              id: @controller.instance_variable_get(:@profiles).first.id.to_s,
              type: 'profiles',
              attributes: {
                name: 'Name 1',
                description: 'Description 1'
              }
            }
          ],
          meta: {
            total: 10
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer_and_links
        get :render_array_using_implicit_serializer_and_links

        expected = {
          data: [
            {
              id: @controller.instance_variable_get(:@profiles).first.id.to_s,
              type: 'profiles',
              attributes: {
                name: 'Name 1',
                description: 'Description 1'
              }
            }
          ],
          links: {
            self: 'http://example.com/api/profiles/1'
          }
        }

        assert_equal 'application/json', @response.content_type
        assert_equal expected.to_json, @response.body
      end

      def test_render_with_cache_enable
        expected = {
          id: 1,
          title: 'New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT'
            }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        ActionController::Base.cache_store.clear
        Timecop.freeze(Time.zone.now) do
          get :render_object_with_cache_enabled

          assert_equal 'application/json', @response.content_type
          assert_equal expected.to_json, @response.body

          get :render_changed_object_with_cache_enabled
          assert_equal expected.to_json, @response.body
        end

        ActionController::Base.cache_store.clear
        get :render_changed_object_with_cache_enabled
        assert_not_equal expected.to_json, @response.body
      end

      def test_render_with_cache_enable_and_expired
        ActionController::Base.cache_store.clear
        get :render_object_expired_with_cache_enabled

        expected = {
          id: 1,
          title: 'ZOMG a New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT'
            }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        assert_equal 'application/json', @response.content_type
        actual   = @response.body
        expected = expected.to_json
        if ENV['APPVEYOR'] && actual != expected
          skip('Cache expiration tests sometimes fail on Appveyor. FIXME :)')
        else
          assert_equal actual, expected
        end
      end

      def test_render_with_fragment_only_cache_enable
        ActionController::Base.cache_store.clear
        get :render_fragment_changed_object_with_only_cache_enabled
        response = JSON.parse(@response.body)

        assert_equal 'application/json', @response.content_type
        assert_equal 'ZOMG A ROLE', response['name']
        assert_equal 'HUEHUEBRBR', response['description']
      end

      def test_render_with_fragment_except_cache_enable
        ActionController::Base.cache_store.clear
        get :render_fragment_changed_object_with_except_cache_enabled
        response = JSON.parse(@response.body)

        assert_equal 'application/json', @response.content_type
        assert_equal 5, response['rating']
        assert_equal 'lol', response['content']
      end

      def test_render_fragment_changed_object_with_relationship
        ActionController::Base.cache_store.clear

        Timecop.freeze(Time.zone.now) do
          get :render_fragment_changed_object_with_relationship
          response = JSON.parse(@response.body)

          expected_return = {
            'id' => 1,
            'time' => Time.zone.now.to_s,
            'likeable' => {
              'id' => 1,
              'body' => 'ZOMG A COMMENT'
            }
          }

          assert_equal 'application/json', @response.content_type
          assert_equal expected_return, response
        end
      end

      def test_cache_expiration_on_update
        ActionController::Base.cache_store.clear
        get :render_object_with_cache_enabled

        expected = {
          id: 1,
          title: 'ZOMG a New Post',
          body: 'Body',
          comments: [
            {
              id: 1,
              body: 'ZOMG A COMMENT'
            }
          ],
          blog: {
            id: 999,
            name: 'Custom blog'
          },
          author: {
            id: 1,
            name: 'Joao Moura.'
          }
        }

        get :update_and_render_object_with_cache_enabled

        assert_equal 'application/json', @response.content_type
        actual   = @response.body
        expected = expected.to_json
        if ENV['APPVEYOR'] && actual != expected
          skip('Cache expiration tests sometimes fail on Appveyor. FIXME :)')
        else
          assert_equal actual, expected
        end
      end

      def test_warn_overridding_use_adapter_as_falsy_on_controller_instance
        controller = Class.new(ImplicitSerializationTestController) do
          def use_adapter?
            false
          end
        end.new
        assert_output(nil, /adapter: false/) do
          controller.get_serializer(Profile.new)
        end
      end

      def test_dont_warn_overridding_use_adapter_as_truthy_on_controller_instance
        controller = Class.new(ImplicitSerializationTestController) do
          def use_adapter?
            true
          end
        end.new
        assert_output(nil, '') do
          controller.get_serializer(Profile.new)
        end
      end

      def test_render_event_is_emitted
        subscriber = ::ActiveSupport::Notifications.subscribe('render.active_model_serializers') do |name|
          @name = name
        end

        get :render_using_implicit_serializer

        assert_equal 'render.active_model_serializers', @name
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      end
    end
  end
end
