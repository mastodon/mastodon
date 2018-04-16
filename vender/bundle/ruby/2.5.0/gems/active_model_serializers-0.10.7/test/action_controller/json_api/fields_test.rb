require 'test_helper'

module ActionController
  module Serialization
    class JsonApi
      class FieldsTest < ActionController::TestCase
        class FieldsTestController < ActionController::Base
          class AuthorWithName < Author
            attributes :first_name, :last_name
          end
          class AuthorWithNameSerializer < AuthorSerializer
            type 'authors'
          end
          class PostWithPublishAt < Post
            attributes :publish_at
          end
          class PostWithPublishAtSerializer < ActiveModel::Serializer
            type 'posts'
            attributes :title, :body, :publish_at
            belongs_to :author
            has_many :comments
          end

          def setup_post
            ActionController::Base.cache_store.clear
            @author = AuthorWithName.new(id: 1, first_name: 'Bob', last_name: 'Jones')
            @comment1 = Comment.new(id: 7, body: 'cool', author: @author)
            @comment2 = Comment.new(id: 12, body: 'awesome', author: @author)
            @post = PostWithPublishAt.new(id: 1337, title: 'Title 1', body: 'Body 1',
                                          author: @author, comments: [@comment1, @comment2],
                                          publish_at: '2020-03-16T03:55:25.291Z')
            @comment1.post = @post
            @comment2.post = @post
          end

          def render_fields_works_on_relationships
            setup_post
            render json: @post, serializer: PostWithPublishAtSerializer, adapter: :json_api, fields: { posts: [:author] }
          end
        end

        tests FieldsTestController

        test 'fields works on relationships' do
          get :render_fields_works_on_relationships
          response = JSON.parse(@response.body)
          expected = {
            'data' => {
              'id' => '1337',
              'type' => 'posts',
              'relationships' => {
                'author' => {
                  'data' => {
                    'id' => '1',
                    'type' => 'authors'
                  }
                }
              }
            }
          }
          assert_equal expected, response
        end
      end
    end
  end
end
