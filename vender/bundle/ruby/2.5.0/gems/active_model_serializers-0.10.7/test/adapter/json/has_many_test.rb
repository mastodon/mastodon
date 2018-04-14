require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Json
      class HasManyTestTest < ActiveSupport::TestCase
        class ModelWithoutSerializer < ::Model
          attributes :id, :name
        end

        def setup
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
          @tag = ModelWithoutSerializer.new(id: 1, name: '#hash_tag')
          @post.tags = [@tag]
        end

        def test_has_many
          serializer = PostSerializer.new(@post)
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer)
          assert_equal([
                         { id: 1, body: 'ZOMG A COMMENT' },
                         { id: 2, body: 'ZOMG ANOTHER COMMENT' }
                       ], adapter.serializable_hash[:post][:comments])
        end

        def test_has_many_with_no_serializer
          post_serializer_class = Class.new(ActiveModel::Serializer) do
            attributes :id
            has_many :tags
          end
          serializer = post_serializer_class.new(@post)
          adapter = ActiveModelSerializers::Adapter::Json.new(serializer)
          assert_equal({
            id: 42,
            tags: [
              { 'id' => 1, 'name' => '#hash_tag' }
            ]
          }.to_json, adapter.serializable_hash[:post].to_json)
        end
      end
    end
  end
end
