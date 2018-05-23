require 'test_helper'

module ActionController
  module Serialization
    class ExplicitSerializerTest < ActionController::TestCase
      class ExplicitSerializerTestController < ActionController::Base
        def render_using_explicit_serializer
          @profile = Profile.new(name: 'Name 1',
                                 description: 'Description 1',
                                 comments: 'Comments 1')
          render json: @profile, serializer: ProfilePreviewSerializer
        end

        def render_array_using_explicit_serializer
          array = [
            Profile.new(name: 'Name 1',
                        description: 'Description 1',
                        comments: 'Comments 1'),
            Profile.new(name: 'Name 2',
                        description: 'Description 2',
                        comments: 'Comments 2')
          ]
          render json: array,
                 serializer: PaginatedSerializer,
                 each_serializer: ProfilePreviewSerializer
        end

        def render_array_using_implicit_serializer
          array = [
            Profile.new(name: 'Name 1',
                        description: 'Description 1',
                        comments: 'Comments 1'),
            Profile.new(name: 'Name 2',
                        description: 'Description 2',
                        comments: 'Comments 2')
          ]
          render json: array,
                 each_serializer: ProfilePreviewSerializer
        end

        def render_array_using_explicit_serializer_and_custom_serializers
          @post = Post.new(title: 'New Post', body: 'Body')
          @author = Author.new(name: 'Jane Blogger')
          @author.posts = [@post]
          @post.author = @author
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @first_comment.post = @post
          @first_comment.author = nil
          @second_comment.post = @post
          @second_comment.author = nil
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @post.blog = @blog

          render json: [@post], each_serializer: PostPreviewSerializer
        end

        def render_using_explicit_each_serializer
          location       = Location.new(id: 42, lat: '-23.550520', lng: '-46.633309')
          place          = Place.new(id: 1337, name: 'Amazing Place', locations: [location])

          render json: place, each_serializer: PlaceSerializer
        end
      end

      tests ExplicitSerializerTestController

      def test_render_using_explicit_serializer
        get :render_using_explicit_serializer

        assert_equal 'application/json', @response.content_type
        assert_equal '{"name":"Name 1"}', @response.body
      end

      def test_render_array_using_explicit_serializer
        get :render_array_using_explicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          { 'name' => 'Name 1' },
          { 'name' => 'Name 2' }
        ]

        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_implicit_serializer
        get :render_array_using_implicit_serializer
        assert_equal 'application/json', @response.content_type

        expected = [
          { 'name' => 'Name 1' },
          { 'name' => 'Name 2' }
        ]
        assert_equal expected.to_json, @response.body
      end

      def test_render_array_using_explicit_serializer_and_custom_serializers
        get :render_array_using_explicit_serializer_and_custom_serializers

        expected = [
          {
            'title' => 'New Post',
            'body' => 'Body',
            'id' => @controller.instance_variable_get(:@post).id,
            'comments' => [{ 'id' => 1 }, { 'id' => 2 }],
            'author' => { 'id' => @controller.instance_variable_get(:@author).id }
          }
        ]

        assert_equal expected.to_json, @response.body
      end

      def test_render_using_explicit_each_serializer
        get :render_using_explicit_each_serializer

        expected = {
          id: 1337,
          name: 'Amazing Place',
          locations: [
            {
              id: 42,
              lat: '-23.550520',
              lng: '-46.633309',
              address: 'Nowhere' # is a virtual attribute on LocationSerializer
            }
          ]
        }

        assert_equal expected.to_json, response.body
      end
    end
  end
end
