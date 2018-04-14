require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class FieldsTest < ActiveSupport::TestCase
        class Post < ::Model
          attributes :title, :body
          associations :author, :comments
        end
        class Author < ::Model
          attributes :name, :birthday
        end
        class Comment < ::Model
          attributes :body
          associations :author, :post
        end

        class PostSerializer < ActiveModel::Serializer
          type 'posts'
          attributes :title, :body
          belongs_to :author
          has_many :comments
        end

        class AuthorSerializer < ActiveModel::Serializer
          type 'authors'
          attributes :name, :birthday
        end

        class CommentSerializer < ActiveModel::Serializer
          type 'comments'
          attributes :body
          belongs_to :author
        end

        def setup
          @author = Author.new(id: 1, name: 'Lucas', birthday: '10.01.1990')
          @comment1 = Comment.new(id: 7, body: 'cool', author: @author)
          @comment2 = Comment.new(id: 12, body: 'awesome', author: @author)
          @post = Post.new(id: 1337, title: 'Title 1', body: 'Body 1',
                           author: @author, comments: [@comment1, @comment2])
          @comment1.post = @post
          @comment2.post = @post
        end

        def test_fields_attributes
          fields = { posts: [:title] }
          hash = serializable(@post, adapter: :json_api, fields: fields).serializable_hash
          expected = {
            title: 'Title 1'
          }

          assert_equal(expected, hash[:data][:attributes])
        end

        def test_fields_relationships
          fields = { posts: [:author] }
          hash = serializable(@post, adapter: :json_api, fields: fields).serializable_hash
          expected = {
            author: {
              data: {
                type: 'authors',
                id: '1'
              }
            }
          }

          assert_equal(expected, hash[:data][:relationships])
        end

        def test_fields_included
          fields = { posts: [:author], comments: [:body] }
          hash = serializable(@post, adapter: :json_api, fields: fields, include: 'comments').serializable_hash
          expected = [
            {
              type: 'comments',
              id: '7',
              attributes: {
                body: 'cool'
              }
            }, {
              type: 'comments',
              id: '12',
              attributes: {
                body: 'awesome'
              }
            }
          ]

          assert_equal(expected, hash[:included])
        end
      end
    end
  end
end
