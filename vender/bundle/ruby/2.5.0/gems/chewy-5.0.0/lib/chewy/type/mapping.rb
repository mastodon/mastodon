module Chewy
  class Type
    module Mapping
      extend ActiveSupport::Concern

      included do
        class_attribute :root_object, instance_reader: false, instance_writer: false
        class_attribute :_templates
        class_attribute :_agg_defs
        self._agg_defs = {}
        class_attribute :outdated_sync_field
        self.outdated_sync_field = :updated_at
      end

      module ClassMethods
        # Defines root object for mapping and is optional for type
        # definition. Use it only if you need to pass options for root
        # object mapping, such as `date_detection` or `dynamic_date_formats`
        #
        # @example
        #   class UsersIndex < Chewy::Index
        #     define_type User do
        #       # root object defined implicitly and optionless for current type
        #       field :full_name, type: 'keyword'
        #     end
        #   end
        #
        #   class CarsIndex < Chewy::Index
        #     define_type Car do
        #       # explicit root definition with additional options
        #       root dynamic_date_formats: ['yyyy-MM-dd'] do
        #         field :model_name, type: 'keyword'
        #       end
        #     end
        #   end
        #
        def root(**options)
          self.root_object ||= Chewy::Fields::Root.new(type_name, Chewy.default_root_options.merge(options))
          root_object.update_options!(options)
          yield if block_given?
          root_object
        end

        # Defines mapping field for current type
        #
        # @example
        #   class UsersIndex < Chewy::Index
        #     define_type User do
        #       # passing all the options to field definition:
        #       field :full_name, analyzer: 'special'
        #     end
        #   end
        #
        # The `type` is optional and defaults to `string` if not defined:
        #
        # @example
        #   field :full_name
        #
        # Also, multiple fields might be defined with one call and
        # with the same options:
        #
        # @example
        #   field :first_name, :last_name, analyzer: 'special'
        #
        # The only special option in the field definition
        # is `:value`. If no `:value` specified then just corresponding
        # method will be called for the indexed object. Also
        # `:value` might be a proc or indexed object method name:
        #
        # @example
        #   class User < ActiveRecord::Base
        #     def user_full_name
        #       [first_name, last_name].join(' ')
        #     end
        #   end
        #
        #   field :full_name, type: 'keyword', value: :user_full_name
        #
        # The proc evaluates inside the indexed object context if
        # its arity is 0 and in present contexts if there is an argument:
        #
        # @example
        #   field :full_name, type: 'keyword', value: -> { [first_name, last_name].join(' ') }
        #
        #   separator = ' '
        #   field :full_name, type: 'keyword', value: ->(user) { [user.first_name, user.last_name].join(separator) }
        #
        # If array was returned as value - it will be put in index as well.
        #
        # @example
        #   field :tags, type: 'keyword', value: -> { tags.map(&:name) }
        #
        # Fields supports nesting in case of `object` field type. If
        # `user.quiz` will return an array of objects, then result index content
        # will be an array of hashes, if `user.quiz` is not a collection association
        # then just values hash will be put in the index.
        #
        # @example
        #   field :quiz do
        #     field :question, :answer
        #     field :score, type: 'integer'
        #   end
        #
        # Nested fields are composed from nested objects:
        #
        # @example
        #   field :name, value: -> { name_translations } do
        #     field :ru, value: ->(name) { name['ru'] }
        #     field :en, value: ->(name) { name['en'] }
        #   end
        #
        # Of course it is possible to define object fields contents dynamically
        # but make sure evaluation proc returns hash:
        #
        # @example
        #   field :name, type: 'object', value: -> { name_translations }
        #
        # The special case is multi_field. If type options and block are
        # both present field is treated as a multi-field. In that case field
        # composition changes satisfy elasticsearch rules:
        #
        # @example
        #   field :full_name, type: 'text', analyzer: 'name', value: ->{ full_name.try(:strip) } do
        #     field :sorted, analyzer: 'sorted'
        #   end
        #
        def field(*args, **options, &block)
          if args.size > 1
            args.map { |name| field(name, options) }
          else
            expand_nested(Chewy::Fields::Base.new(args.first, options), &block)
          end
        end

        # Defines an aggregation that can be bound to a query or filter
        #
        # @example
        #   # Suppose that a user has posts and each post has ratings
        #   # avg_post_rating is the mean of all ratings
        #   class UsersIndex < Chewy::Index
        #     define_type User do
        #       field :posts do
        #         field :rating
        #       end
        #
        #       agg :avg_rating do
        #         { avg: { field: 'posts.rating' } }
        #       end
        #     end
        #   end
        def agg(name, &block)
          self._agg_defs = _agg_defs.merge(name => block)
        end
        alias_method :aggregation, :agg

        # Defines dynamic template in mapping root objects
        #
        # @example
        #   class CarsIndex < Chewy::Index
        #     define_type Car do
        #       template 'model.*', type: 'text', analyzer: 'special'
        #       field 'model', type: 'object' # here we can put { de: 'Der Mercedes', en: 'Mercedes' }
        #                                     # and template will be applyed to this field
        #     end
        #   end
        #
        # Name for each template is generated with the following
        # rule: `template_#!{dynamic_templates.size + 1}`.
        #
        # @example Templates
        #   template 'tit*', mapping_hash
        #   template 'title.*', mapping_hash # dot in template causes "path_match" using
        #   template /tit.+/, mapping_hash # using "match_pattern": "regexp"
        #   template /title\..+/, mapping_hash # "\." - escaped dot causes "path_match" using
        #   template /tit.+/, type: 'text', mapping_hash # "match_mapping_type" as the optionsl second argument
        #   template template42: {match: 'hello*', mapping: {type: 'object'}} # or even pass a template as is
        #
        def template(*args)
          root.dynamic_template(*args)
        end
        alias_method :dynamic_template, :template

        # Returns compiled mappings hash for current type
        #
        def mappings_hash
          root.mappings_hash[type_name.to_sym].present? ? root.mappings_hash : {}
        end

        # Check whether the type has outdated_sync_field defined with a simple value.
        #
        # @return [true, false]
        def supports_outdated_sync?
          updated_at_field = root.child_hash[outdated_sync_field] if outdated_sync_field
          !!updated_at_field && updated_at_field.value.nil?
        end

      private

        def expand_nested(field)
          @_current_field ||= root

          if @_current_field
            field.parent = @_current_field
            @_current_field.children.push(field)
          end

          return unless block_given?

          previous_field = @_current_field
          @_current_field = field
          yield
          @_current_field = previous_field
        end
      end
    end
  end
end
