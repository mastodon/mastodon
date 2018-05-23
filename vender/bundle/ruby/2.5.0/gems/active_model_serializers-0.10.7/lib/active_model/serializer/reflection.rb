require 'active_model/serializer/field'
require 'active_model/serializer/association'

module ActiveModel
  class Serializer
    # Holds all the meta-data about an association as it was specified in the
    # ActiveModel::Serializer class.
    #
    # @example
    #   class PostSerializer < ActiveModel::Serializer
    #     has_one :author, serializer: AuthorSerializer
    #     belongs_to :boss, type: :users, foreign_key: :boss_id
    #     has_many :comments
    #     has_many :comments, key: :last_comments do
    #       object.comments.last(1)
    #     end
    #     has_many :secret_meta_data, if: :is_admin?
    #
    #     has_one :blog do |serializer|
    #       meta count: object.roles.count
    #       serializer.cached_blog
    #     end
    #
    #     private
    #
    #     def cached_blog
    #       cache_store.fetch("cached_blog:#{object.updated_at}") do
    #         Blog.find(object.blog_id)
    #       end
    #     end
    #
    #     def is_admin?
    #       current_user.admin?
    #     end
    #   end
    #
    #  Specifically, the association 'comments' is evaluated two different ways:
    #  1) as 'comments' and named 'comments'.
    #  2) as 'object.comments.last(1)' and named 'last_comments'.
    #
    #  PostSerializer._reflections # =>
    #    # {
    #    #   author: HasOneReflection.new(:author, serializer: AuthorSerializer),
    #    #   comments: HasManyReflection.new(:comments)
    #    #   last_comments: HasManyReflection.new(:comments, { key: :last_comments }, #<Block>)
    #    #   secret_meta_data: HasManyReflection.new(:secret_meta_data, { if: :is_admin? })
    #    # }
    #
    # So you can inspect reflections in your Adapters.
    class Reflection < Field
      attr_reader :foreign_key, :type

      def initialize(*)
        super
        options[:links] = {}
        options[:include_data_setting] = Serializer.config.include_data_default
        options[:meta] = nil
        @type = options.fetch(:type) do
          class_name = options.fetch(:class_name, name.to_s.camelize.singularize)
          class_name.underscore.pluralize.to_sym
        end
        @foreign_key = options.fetch(:foreign_key) do
          if collection?
            "#{name.to_s.singularize}_ids".to_sym
          else
            "#{name}_id".to_sym
          end
        end
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #     link :self, '//example.com/link_author/relationships/bio'
      #     id = object.profile.id
      #     link :related do
      #       "//example.com/profiles/#{id}" if id != 123
      #     end
      #     link :related do
      #       ids = object.likes.map(&:id).join(',')
      #       href "//example.com/likes/#{ids}"
      #       meta ids: ids
      #     end
      #   end
      def link(name, value = nil)
        options[:links][name] = block_given? ? Proc.new : value
        :nil
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     meta(id: object.blog.id)
      #     meta liked: object.likes.any?
      #     link :self do
      #       href object.blog.id.to_s
      #       meta(id: object.blog.id)
      #     end
      def meta(value = nil)
        options[:meta] = block_given? ? Proc.new : value
        :nil
      end

      # @api public
      # @example
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #   end
      #
      #   has_one :blog do
      #     include_data false
      #     link :self, 'a link'
      #     link :related, 'another link'
      #   end
      #
      #    belongs_to :reviewer do
      #      meta name: 'Dan Brown'
      #      include_data true
      #    end
      #
      #    has_many :tags, serializer: TagSerializer do
      #      link :self, '//example.com/link_author/relationships/tags'
      #      include_data :if_sideloaded
      #    end
      def include_data(value = true)
        options[:include_data_setting] = value
        :nil
      end

      def collection?
        false
      end

      def include_data?(include_slice)
        include_data_setting = options[:include_data_setting]
        case include_data_setting
        when :if_sideloaded then include_slice.key?(options.fetch(:key, name))
        when true           then true
        when false          then false
        else fail ArgumentError, "Unknown include_data_setting '#{include_data_setting.inspect}'"
        end
      end

      # @param serializer [ActiveModel::Serializer]
      # @yield [ActiveModel::Serializer]
      # @return [:nil, associated resource or resource collection]
      def value(serializer, include_slice)
        @object = serializer.object
        @scope = serializer.scope

        block_value = instance_exec(serializer, &block) if block
        return unless include_data?(include_slice)

        if block && block_value != :nil
          block_value
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      # @api private
      def foreign_key_on
        :related
      end

      # Build association. This method is used internally to
      # build serializer's association by its reflection.
      #
      # @param [Serializer] parent_serializer for given association
      # @param [Hash{Symbol => Object}] parent_serializer_options
      #
      # @example
      #    # Given the following serializer defined:
      #    class PostSerializer < ActiveModel::Serializer
      #      has_many :comments, serializer: CommentSummarySerializer
      #    end
      #
      #    # Then you instantiate your serializer
      #    post_serializer = PostSerializer.new(post, foo: 'bar') #
      #    # to build association for comments you need to get reflection
      #    comments_reflection = PostSerializer._reflections.detect { |r| r.name == :comments }
      #    # and #build_association
      #    comments_reflection.build_association(post_serializer, foo: 'bar')
      #
      # @api private
      def build_association(parent_serializer, parent_serializer_options, include_slice = {})
        association_options = {
          parent_serializer: parent_serializer,
          parent_serializer_options: parent_serializer_options,
          include_slice: include_slice
        }
        Association.new(self, association_options)
      end

      protected

      # used in instance exec
      attr_accessor :object, :scope
    end
  end
end
