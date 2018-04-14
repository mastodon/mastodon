require 'test_helper'
module ActiveModel
  class Serializer
    class AssociationsTest < ActiveSupport::TestCase
      class ModelWithoutSerializer < ::Model
        attributes :id, :name
      end

      def setup
        @author = Author.new(name: 'Steve K.')
        @author.bio = nil
        @author.roles = []
        @blog = Blog.new(name: 'AMS Blog')
        @post = Post.new(title: 'New Post', body: 'Body')
        @tag = ModelWithoutSerializer.new(id: 'tagid', name: '#hashtagged')
        @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
        @post.comments = [@comment]
        @post.tags = [@tag]
        @post.blog = @blog
        @comment.post = @post
        @comment.author = nil
        @post.author = @author
        @author.posts = [@post]

        @post_serializer = PostSerializer.new(@post, custom_options: true)
        @author_serializer = AuthorSerializer.new(@author)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_has_many_and_has_one
        @author_serializer.associations.each do |association|
          key = association.key
          serializer = association.lazy_association.serializer

          case key
          when :posts
            assert_equal true, association.include_data?
            assert_kind_of(ActiveModelSerializers.config.collection_serializer, serializer)
          when :bio
            assert_equal true, association.include_data?
            assert_nil serializer
          when :roles
            assert_equal true, association.include_data?
            assert_kind_of(ActiveModelSerializers.config.collection_serializer, serializer)
          else
            flunk "Unknown association: #{key}"
          end
        end
      end

      def test_has_many_with_no_serializer
        post_serializer_class = Class.new(ActiveModel::Serializer) do
          attributes :id
          has_many :tags
        end
        post_serializer_class.new(@post).associations.each do |association|
          key = association.key
          serializer = association.lazy_association.serializer

          assert_equal :tags, key
          assert_nil serializer
          assert_equal [{ id: 'tagid', name: '#hashtagged' }].to_json, association.virtual_value.to_json
        end
      end

      def test_serializer_options_are_passed_into_associations_serializers
        association = @post_serializer
                      .associations
                      .detect { |assoc| assoc.key == :comments }

        comment_serializer = association.lazy_association.serializer.first
        class << comment_serializer
          def custom_options
            instance_options
          end
        end
        assert comment_serializer.custom_options.fetch(:custom_options)
      end

      def test_belongs_to
        @comment_serializer.associations.each do |association|
          key = association.key
          serializer = association.lazy_association.serializer

          case key
          when :post
            assert_kind_of(PostSerializer, serializer)
          when :author
            assert_nil serializer
          else
            flunk "Unknown association: #{key}"
          end

          assert_equal true, association.include_data?
        end
      end

      def test_belongs_to_with_custom_method
        assert(
          @post_serializer.associations.any? do |association|
            association.key == :blog
          end
        )
      end

      def test_associations_inheritance
        inherited_klass = Class.new(PostSerializer)

        assert_equal(PostSerializer._reflections, inherited_klass._reflections)
      end

      def test_associations_inheritance_with_new_association
        inherited_klass = Class.new(PostSerializer) do
          has_many :top_comments, serializer: CommentSerializer
        end

        assert(
          PostSerializer._reflections.values.all? do |reflection|
            inherited_klass._reflections.values.include?(reflection)
          end
        )

        assert(
          inherited_klass._reflections.values.any? do |reflection|
            reflection.name == :top_comments
          end
        )
      end

      def test_associations_custom_keys
        serializer = PostWithCustomKeysSerializer.new(@post)

        expected_association_keys = serializer.associations.map(&:key)

        assert expected_association_keys.include? :reviews
        assert expected_association_keys.include? :writer
        assert expected_association_keys.include? :site
      end

      class BelongsToBlogModel < ::Model
        attributes :id, :title
        associations :blog
      end
      class BelongsToBlogModelSerializer < ActiveModel::Serializer
        type :posts
        belongs_to :blog
      end

      def test_belongs_to_doesnt_load_record
        attributes = { id: 1, title: 'Belongs to Blog', blog: Blog.new(id: 5) }
        post = BelongsToBlogModel.new(attributes)
        class << post
          def blog
            fail 'should use blog_id'
          end

          def blog_id
            5
          end
        end

        actual =
          begin
            original_option = BelongsToBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship
            BelongsToBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship = true
            serializable(post, adapter: :json_api, serializer: BelongsToBlogModelSerializer).as_json
          ensure
            BelongsToBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship = original_option
          end
        expected = { data: { id: '1', type: 'posts', relationships: { blog: { data: { id: '5', type: 'blogs' } } } } }

        assert_equal expected, actual
      end

      class ExternalBlog < Blog
        attributes :external_id
      end
      class BelongsToExternalBlogModel < ::Model
        attributes :id, :title, :external_blog_id
        associations :external_blog
      end
      class BelongsToExternalBlogModelSerializer < ActiveModel::Serializer
        type :posts
        belongs_to :external_blog

        def external_blog_id
          object.external_blog.external_id
        end
      end

      def test_belongs_to_allows_id_overwriting
        attributes = {
          id: 1,
          title: 'Title',
          external_blog: ExternalBlog.new(id: 5, external_id: 6)
        }
        post = BelongsToExternalBlogModel.new(attributes)

        actual =
          begin
            original_option = BelongsToExternalBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship
            BelongsToExternalBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship = true
            serializable(post, adapter: :json_api, serializer: BelongsToExternalBlogModelSerializer).as_json
          ensure
            BelongsToExternalBlogModelSerializer.config.jsonapi_use_foreign_key_on_belongs_to_relationship = original_option
          end
        expected = { data: { id: '1', type: 'posts', relationships: { :'external-blog' => { data: { id: '6', type: 'external-blogs' } } } } }

        assert_equal expected, actual
      end

      class InlineAssociationTestPostSerializer < ActiveModel::Serializer
        has_many :comments
        has_many :comments, key: :last_comments do
          object.comments.last(1)
        end
      end

      def test_virtual_attribute_block
        comment1 = ::ARModels::Comment.create!(contents: 'first comment')
        comment2 = ::ARModels::Comment.create!(contents: 'last comment')
        post = ::ARModels::Post.create!(
          title: 'inline association test',
          body: 'etc',
          comments: [comment1, comment2]
        )
        actual = serializable(post, adapter: :attributes, serializer: InlineAssociationTestPostSerializer).as_json
        expected = {
          comments: [
            { id: 1, contents: 'first comment' },
            { id: 2, contents: 'last comment' }
          ],
          last_comments: [
            { id: 2, contents: 'last comment' }
          ]
        }

        assert_equal expected, actual
      ensure
        ::ARModels::Post.delete_all
        ::ARModels::Comment.delete_all
      end

      class NamespacedResourcesTest < ActiveSupport::TestCase
        class ResourceNamespace
          class Post < ::Model
            associations :comments, :author, :description
          end
          class Comment < ::Model; end
          class Author  < ::Model; end
          class Description < ::Model; end
          class PostSerializer < ActiveModel::Serializer
            has_many :comments
            belongs_to :author
            has_one :description
          end
          class CommentSerializer     < ActiveModel::Serializer; end
          class AuthorSerializer      < ActiveModel::Serializer; end
          class DescriptionSerializer < ActiveModel::Serializer; end
        end

        def setup
          @comment = ResourceNamespace::Comment.new
          @author = ResourceNamespace::Author.new
          @description = ResourceNamespace::Description.new
          @post = ResourceNamespace::Post.new(comments: [@comment],
                                              author: @author,
                                              description: @description)
          @post_serializer = ResourceNamespace::PostSerializer.new(@post)
        end

        def test_associations_namespaced_resources
          @post_serializer.associations.each do |association|
            case association.key
            when :comments
              assert_instance_of(ResourceNamespace::CommentSerializer, association.lazy_association.serializer.first)
            when :author
              assert_instance_of(ResourceNamespace::AuthorSerializer, association.lazy_association.serializer)
            when :description
              assert_instance_of(ResourceNamespace::DescriptionSerializer, association.lazy_association.serializer)
            else
              flunk "Unknown association: #{key}"
            end
          end
        end
      end

      class NestedSerializersTest < ActiveSupport::TestCase
        class Post < ::Model
          associations :comments, :author, :description
        end
        class Comment < ::Model; end
        class Author  < ::Model; end
        class Description < ::Model; end
        class PostSerializer < ActiveModel::Serializer
          has_many :comments
          class CommentSerializer < ActiveModel::Serializer; end
          belongs_to :author
          class AuthorSerializer < ActiveModel::Serializer; end
          has_one :description
          class DescriptionSerializer < ActiveModel::Serializer; end
        end

        def setup
          @comment = Comment.new
          @author = Author.new
          @description = Description.new
          @post = Post.new(comments: [@comment],
                           author: @author,
                           description: @description)
          @post_serializer = PostSerializer.new(@post)
        end

        def test_associations_namespaced_resources
          @post_serializer.associations.each do |association|
            case association.key
            when :comments
              assert_instance_of(PostSerializer::CommentSerializer, association.lazy_association.serializer.first)
            when :author
              assert_instance_of(PostSerializer::AuthorSerializer, association.lazy_association.serializer)
            when :description
              assert_instance_of(PostSerializer::DescriptionSerializer, association.lazy_association.serializer)
            else
              flunk "Unknown association: #{key}"
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        def test_conditional_associations
          model = Class.new(::Model) do
            attributes :true, :false
            associations :something
          end.new(true: true, false: false)

          scenarios = [
            { options: { if:     :true  }, included: true  },
            { options: { if:     :false }, included: false },
            { options: { unless: :false }, included: true  },
            { options: { unless: :true  }, included: false },
            { options: { if:     'object.true'  }, included: true  },
            { options: { if:     'object.false' }, included: false },
            { options: { unless: 'object.false' }, included: true  },
            { options: { unless: 'object.true'  }, included: false },
            { options: { if:     -> { object.true }  }, included: true  },
            { options: { if:     -> { object.false } }, included: false },
            { options: { unless: -> { object.false } }, included: true  },
            { options: { unless: -> { object.true }  }, included: false },
            { options: { if:     -> (s) { s.object.true }  }, included: true  },
            { options: { if:     -> (s) { s.object.false } }, included: false },
            { options: { unless: -> (s) { s.object.false } }, included: true  },
            { options: { unless: -> (s) { s.object.true }  }, included: false }
          ]

          scenarios.each do |s|
            serializer = Class.new(ActiveModel::Serializer) do
              belongs_to :something, s[:options]

              def true
                true
              end

              def false
                false
              end
            end

            hash = serializable(model, serializer: serializer).serializable_hash
            assert_equal(s[:included], hash.key?(:something), "Error with #{s[:options]}")
          end
        end

        def test_illegal_conditional_associations
          exception = assert_raises(TypeError) do
            Class.new(ActiveModel::Serializer) do
              belongs_to :x, if: nil
            end
          end

          assert_match(/:if should be a Symbol, String or Proc/, exception.message)
        end
      end

      class InheritedSerializerTest < ActiveSupport::TestCase
        class PostSerializer < ActiveModel::Serializer
          belongs_to :author
          has_many :comments
          belongs_to :blog
        end

        class InheritedPostSerializer < PostSerializer
          belongs_to :author, polymorphic: true
          has_many :comments, key: :reviews
        end

        class AuthorSerializer < ActiveModel::Serializer
          has_many :posts
          has_many :roles
          has_one :bio
        end

        class InheritedAuthorSerializer < AuthorSerializer
          has_many :roles, polymorphic: true
          has_one :bio, polymorphic: true
        end

        def setup
          @author = Author.new(name: 'Steve K.')
          @post = Post.new(title: 'New Post', body: 'Body')
          @post_serializer = PostSerializer.new(@post)
          @author_serializer = AuthorSerializer.new(@author)
          @inherited_post_serializer = InheritedPostSerializer.new(@post)
          @inherited_author_serializer = InheritedAuthorSerializer.new(@author)
          @author_associations = @author_serializer.associations.to_a.sort_by(&:name)
          @inherited_author_associations = @inherited_author_serializer.associations.to_a.sort_by(&:name)
          @post_associations = @post_serializer.associations.to_a
          @inherited_post_associations = @inherited_post_serializer.associations.to_a
        end

        test 'an author serializer must have [posts,roles,bio] associations' do
          expected = [:posts, :roles, :bio].sort
          result = @author_serializer.associations.map(&:name).sort
          assert_equal(result, expected)
        end

        test 'a post serializer must have [author,comments,blog] associations' do
          expected = [:author, :comments, :blog].sort
          result = @post_serializer.associations.map(&:name).sort
          assert_equal(result, expected)
        end

        test 'a serializer inheriting from another serializer can redefine has_many and has_one associations' do
          expected = [:roles, :bio].sort
          result = (@inherited_author_associations.map(&:reflection) - @author_associations.map(&:reflection)).map(&:name)
          assert_equal(result, expected)
          assert_equal [true, false, true], @inherited_author_associations.map(&:polymorphic?)
          assert_equal [false, false, false], @author_associations.map(&:polymorphic?)
        end

        test 'a serializer inheriting from another serializer can redefine belongs_to associations' do
          assert_equal [:author, :comments, :blog], @post_associations.map(&:name)
          assert_equal [:author, :comments, :blog, :comments], @inherited_post_associations.map(&:name)

          refute @post_associations.detect { |assoc| assoc.name == :author }.polymorphic?
          assert @inherited_post_associations.detect { |assoc| assoc.name == :author }.polymorphic?

          refute @post_associations.detect { |assoc| assoc.name == :comments }.key?
          original_comment_assoc, new_comments_assoc = @inherited_post_associations.select { |assoc| assoc.name == :comments }
          refute original_comment_assoc.key?
          assert_equal :reviews, new_comments_assoc.key

          original_blog = @post_associations.detect { |assoc| assoc.name == :blog }
          inherited_blog = @inherited_post_associations.detect { |assoc| assoc.name == :blog }
          original_parent_serializer = original_blog.lazy_association.association_options.delete(:parent_serializer)
          inherited_parent_serializer = inherited_blog.lazy_association.association_options.delete(:parent_serializer)
          assert_equal PostSerializer, original_parent_serializer.class
          assert_equal InheritedPostSerializer, inherited_parent_serializer.class
        end

        test 'a serializer inheriting from another serializer can have an additional association with the same name but with different key' do
          expected = [:author, :comments, :blog, :reviews].sort
          result = @inherited_post_serializer.associations.map(&:key).sort
          assert_equal(result, expected)
        end
      end
    end
  end
end
