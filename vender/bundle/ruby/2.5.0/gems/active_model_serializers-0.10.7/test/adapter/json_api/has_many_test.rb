require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class HasManyTest < ActiveSupport::TestCase
        class ModelWithoutSerializer < ::Model
          attributes :id, :name
        end

        def setup
          ActionController::Base.cache_store.clear
          @author = Author.new(id: 1, name: 'Steve K.')
          @author.posts = []
          @author.bio = nil
          @post = Post.new(id: 1, title: 'New Post', body: 'Body')
          @post_without_comments = Post.new(id: 2, title: 'Second Post', body: 'Second')
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @first_comment.author = nil
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @second_comment.author = nil
          @post.comments = [@first_comment, @second_comment]
          @post_without_comments.comments = []
          @first_comment.post = @post
          @second_comment.post = @post
          @post.author = @author
          @post_without_comments.author = nil
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @blog.writer = @author
          @blog.articles = [@post]
          @post.blog = @blog
          @post_without_comments.blog = nil
          @tag = ModelWithoutSerializer.new(id: 1, name: '#hash_tag')
          @post.tags = [@tag]
          @serializer = PostSerializer.new(@post)
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer)

          @virtual_value = VirtualValue.new(id: 1)
        end

        def test_includes_comment_ids
          expected = { data: [{ type: 'comments', id: '1' }, { type: 'comments', id: '2' }] }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:comments])
        end

        test 'relationships can be whitelisted via fields' do
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, fields: { posts: [:author] })
          result = @adapter.serializable_hash
          expected = {
            data: {
              id: '1',
              type: 'posts',
              relationships: {
                author: {
                  data: {
                    id: '1',
                    type: 'authors'
                  }
                }
              }
            }
          }

          assert_equal expected, result
        end

        def test_includes_linked_comments
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:comments])
          expected = [{
            id: '1',
            type: 'comments',
            attributes: {
              body: 'ZOMG A COMMENT'
            },
            relationships: {
              post: { data: { type: 'posts', id: '1' } },
              author: { data: nil }
            }
          }, {
            id: '2',
            type: 'comments',
            attributes: {
              body: 'ZOMG ANOTHER COMMENT'
            },
            relationships: {
              post: { data: { type: 'posts', id: '1' } },
              author: { data: nil }
            }
          }]
          assert_equal expected, @adapter.serializable_hash[:included]
        end

        def test_limit_fields_of_linked_comments
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:comments], fields: { comment: [:id, :post, :author] })
          expected = [{
            id: '1',
            type: 'comments',
            relationships: {
              post: { data: { type: 'posts', id: '1' } },
              author: { data: nil }
            }
          }, {
            id: '2',
            type: 'comments',
            relationships: {
              post: { data: { type: 'posts', id: '1' } },
              author: { data: nil }
            }
          }]
          assert_equal expected, @adapter.serializable_hash[:included]
        end

        def test_no_include_linked_if_comments_is_empty
          serializer = PostSerializer.new(@post_without_comments)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)

          assert_nil adapter.serializable_hash[:linked]
        end

        def test_include_type_for_association_when_different_than_name
          serializer = BlogSerializer.new(@blog)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
          actual = adapter.serializable_hash[:data][:relationships][:articles]

          expected = {
            data: [{
              type: 'posts',
              id: '1'
            }]
          }
          assert_equal expected, actual
        end

        def test_has_many_with_no_serializer
          post_serializer_class = Class.new(ActiveModel::Serializer) do
            attributes :id
            has_many :tags
          end
          serializer = post_serializer_class.new(@post)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)

          assert_equal({
                         data: {
                           id: '1',
                           type: 'posts',
                           relationships: {
                             tags: { data: [@tag.as_json] }
                           }
                         }
                       }, adapter.serializable_hash)
        end

        def test_has_many_with_virtual_value
          serializer = VirtualValueSerializer.new(@virtual_value)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)

          assert_equal({
                         data: {
                           id: '1',
                           type: 'virtual-values',
                           relationships: {
                             maker: { data: { type: 'makers', id: '1' } },
                             reviews: { data: [{ type: 'reviews', id: '1' },
                                               { type: 'reviews', id: '2' }] }
                           }
                         }
                       }, adapter.serializable_hash)
        end
      end
    end
  end
end
