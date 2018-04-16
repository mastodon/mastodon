require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class BelongsToTest < ActiveSupport::TestCase
        def setup
          @author = Author.new(id: 1, name: 'Steve K.')
          @author.bio = nil
          @author.roles = []
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @post = Post.new(id: 42, title: 'New Post', body: 'Body')
          @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
          @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @post.comments = [@comment]
          @post.blog = @blog
          @anonymous_post.comments = []
          @anonymous_post.blog = nil
          @comment.post = @post
          @comment.author = nil
          @post.author = @author
          @anonymous_post.author = nil
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @blog.writer = @author
          @blog.articles = [@post, @anonymous_post]
          @author.posts = []

          @serializer = CommentSerializer.new(@comment)
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer)
          ActionController::Base.cache_store.clear
        end

        def test_includes_post_id
          expected = { data: { type: 'posts', id: '42' } }

          assert_equal(expected, @adapter.serializable_hash[:data][:relationships][:post])
        end

        def test_includes_linked_post
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:post])
          expected = [{
            id: '42',
            type: 'posts',
            attributes: {
              title: 'New Post',
              body: 'Body'
            },
            relationships: {
              comments: { data: [{ type: 'comments', id: '1' }] },
              blog: { data: { type: 'blogs', id: '999' } },
              author: { data: { type: 'authors', id: '1' } }
            }
          }]
          assert_equal expected, @adapter.serializable_hash[:included]
        end

        def test_limiting_linked_post_fields
          @adapter = ActiveModelSerializers::Adapter::JsonApi.new(@serializer, include: [:post], fields: { post: [:title, :comments, :blog, :author] })
          expected = [{
            id: '42',
            type: 'posts',
            attributes: {
              title: 'New Post'
            },
            relationships: {
              comments: { data: [{ type: 'comments', id: '1' }] },
              blog: { data: { type: 'blogs', id: '999' } },
              author: { data: { type: 'authors', id: '1' } }
            }
          }]
          assert_equal expected, @adapter.serializable_hash[:included]
        end

        def test_include_nil_author
          serializer = PostSerializer.new(@anonymous_post)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)

          assert_equal({ comments: { data: [] }, blog: { data: { type: 'blogs', id: '999' } }, author: { data: nil } }, adapter.serializable_hash[:data][:relationships])
        end

        def test_include_type_for_association_when_different_than_name
          serializer = BlogSerializer.new(@blog)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
          relationships = adapter.serializable_hash[:data][:relationships]
          expected = {
            writer: {
              data: {
                type: 'authors',
                id: '1'
              }
            },
            articles: {
              data: [
                {
                  type: 'posts',
                  id: '42'
                },
                {
                  type: 'posts',
                  id: '43'
                }
              ]
            }
          }
          assert_equal expected, relationships
        end

        def test_include_linked_resources_with_type_name
          serializer = BlogSerializer.new(@blog)
          adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer, include: [:writer, :articles])
          linked = adapter.serializable_hash[:included]
          expected = [
            {
              id: '1',
              type: 'authors',
              attributes: {
                name: 'Steve K.'
              },
              relationships: {
                posts: { data: [] },
                roles: { data: [] },
                bio: { data: nil }
              }
            }, {
              id: '42',
              type: 'posts',
              attributes: {
                title: 'New Post',
                body: 'Body'
              },
              relationships: {
                comments: { data: [{ type: 'comments', id: '1' }] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: { type: 'authors', id: '1' } }
              }
            }, {
              id: '43',
              type: 'posts',
              attributes: {
                title: 'Hello!!',
                body: 'Hello, world!!'
              },
              relationships: {
                comments: { data: [] },
                blog: { data: { type: 'blogs', id: '999' } },
                author: { data: nil }
              }
            }
          ]
          assert_equal expected, linked
        end
      end
    end
  end
end
