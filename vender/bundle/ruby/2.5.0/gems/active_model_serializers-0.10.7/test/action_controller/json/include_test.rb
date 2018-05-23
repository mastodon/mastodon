require 'test_helper'

module ActionController
  module Serialization
    class Json
      class IncludeTest < ActionController::TestCase
        INCLUDE_STRING = 'posts.comments'.freeze
        INCLUDE_HASH = { posts: :comments }.freeze
        DEEP_INCLUDE = 'posts.comments.author'.freeze

        class IncludeTestController < ActionController::Base
          def setup_data
            ActionController::Base.cache_store.clear

            @author = Author.new(id: 1, name: 'Steve K.')

            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')

            @post.comments = [@first_comment, @second_comment]
            @post.author = @author

            @first_comment.post = @post
            @second_comment.post = @post

            @blog = Blog.new(id: 1, name: 'My Blog!!')
            @post.blog = @blog
            @author.posts = [@post]

            @first_comment.author = @author
            @second_comment.author = @author
            @author.comments = [@first_comment, @second_comment]
            @author.roles = []
            @author.bio = {}
          end

          def render_without_include
            setup_data
            render json: @author, adapter: :json
          end

          def render_resource_with_include_hash
            setup_data
            render json: @author, include: INCLUDE_HASH, adapter: :json
          end

          def render_resource_with_include_string
            setup_data
            render json: @author, include: INCLUDE_STRING, adapter: :json
          end

          def render_resource_with_deep_include
            setup_data
            render json: @author, include: DEEP_INCLUDE, adapter: :json
          end

          def render_without_recursive_relationships
            # testing recursive includes ('**') can't have any cycles in the
            # relationships, or we enter an infinite loop.
            author = Author.new(id: 11, name: 'Jane Doe')
            post = Post.new(id: 12, title: 'Hello World', body: 'My first post')
            comment = Comment.new(id: 13, body: 'Commentary')
            author.posts = [post]
            post.comments = [comment]
            render json: author
          end
        end

        tests IncludeTestController

        def test_render_without_include
          get :render_without_include
          response = JSON.parse(@response.body)
          expected = {
            'author' => {
              'id' => 1,
              'name' => 'Steve K.',
              'posts' => [
                {
                  'id' => 42, 'title' => 'New Post', 'body' => 'Body'
                }
              ],
              'roles' => [],
              'bio' => {}
            }
          }

          assert_equal(expected, response)
        end

        def test_render_resource_with_include_hash
          get :render_resource_with_include_hash
          response = JSON.parse(@response.body)

          assert_equal(expected_include_response, response)
        end

        def test_render_resource_with_include_string
          get :render_resource_with_include_string

          response = JSON.parse(@response.body)

          assert_equal(expected_include_response, response)
        end

        def test_render_resource_with_deep_include
          get :render_resource_with_deep_include

          response = JSON.parse(@response.body)

          assert_equal(expected_deep_include_response, response)
        end

        def test_render_with_empty_default_includes
          with_default_includes '' do
            get :render_without_include
            response = JSON.parse(@response.body)
            expected = {
              'author' => {
                'id' => 1,
                'name' => 'Steve K.'
              }
            }
            assert_equal(expected, response)
          end
        end

        def test_render_with_recursive_default_includes
          with_default_includes '**' do
            get :render_without_recursive_relationships
            response = JSON.parse(@response.body)

            expected = {
              'id' => 11,
              'name' => 'Jane Doe',
              'roles' => nil,
              'bio' => nil,
              'posts' => [
                {
                  'id' => 12,
                  'title' => 'Hello World',
                  'body' => 'My first post',
                  'comments' => [
                    {
                      'id' => 13,
                      'body' => 'Commentary',
                      'post' => nil, # not set to avoid infinite recursion
                      'author' => nil, # not set to avoid infinite recursion
                    }
                  ],
                  'blog' => {
                    'id' => 999,
                    'name' => 'Custom blog',
                    'writer' => nil,
                    'articles' => nil
                  },
                  'author' => nil # not set to avoid infinite recursion
                }
              ]
            }
            assert_equal(expected, response)
          end
        end

        def test_render_with_includes_overrides_default_includes
          with_default_includes '' do
            get :render_resource_with_include_hash
            response = JSON.parse(@response.body)

            assert_equal(expected_include_response, response)
          end
        end

        private

        def expected_include_response
          {
            'author' => {
              'id' => 1,
              'name' => 'Steve K.',
              'posts' => [
                {
                  'id' => 42, 'title' => 'New Post', 'body' => 'Body',
                  'comments' => [
                    {
                      'id' => 1, 'body' => 'ZOMG A COMMENT'
                    },
                    {
                      'id' => 2, 'body' => 'ZOMG ANOTHER COMMENT'
                    }
                  ]
                }
              ]
            }
          }
        end

        def expected_deep_include_response
          {
            'author' => {
              'id' => 1,
              'name' => 'Steve K.',
              'posts' => [
                {
                  'id' => 42, 'title' => 'New Post', 'body' => 'Body',
                  'comments' => [
                    {
                      'id' => 1, 'body' => 'ZOMG A COMMENT',
                      'author' => {
                        'id' => 1,
                        'name' => 'Steve K.'
                      }
                    },
                    {
                      'id' => 2, 'body' => 'ZOMG ANOTHER COMMENT',
                      'author' => {
                        'id' => 1,
                        'name' => 'Steve K.'
                      }
                    }
                  ]
                }
              ]
            }
          }
        end

        def with_default_includes(include_directive)
          original = ActiveModelSerializers.config.default_includes
          ActiveModelSerializers.config.default_includes = include_directive
          clear_include_directive_cache
          yield
        ensure
          ActiveModelSerializers.config.default_includes = original
          clear_include_directive_cache
        end

        def clear_include_directive_cache
          ActiveModelSerializers
            .instance_variable_set(:@default_include_directive, nil)
        end
      end
    end
  end
end
