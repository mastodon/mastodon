require 'chewy/search'
require 'chewy/index/actions'
require 'chewy/index/aliases'
require 'chewy/index/settings'
require 'chewy/index/specification'

module Chewy
  class Index
    include Search
    include Actions
    include Aliases

    singleton_class.delegate :client, to: 'Chewy'

    class_attribute :type_hash
    self.type_hash = {}

    class_attribute :_settings
    self._settings = Chewy::Index::Settings.new

    class << self
      # @overload index_name(suggest)
      #   If suggested name is passed, it is set up as the new base name for
      #   the index. Used for the index base name redefinition.
      #
      #   @example
      #     class UsersIndex < Chewy::Index
      #       index_name :legacy_users
      #     end
      #     UsersIndex.index_name # => 'legacy_users'
      #
      #   @param suggest [String, Symbol] suggested base name
      #   @return [String] new base name
      #
      # @overload index_name(prefix: nil, suffix: nil)
      #   If suggested name is not passed, returns the base name accompanied
      #   with the prefix (if any) and suffix (if passed).
      #
      #   @example
      #     class UsersIndex < Chewy::Index
      #     end
      #
      #     Chewy.settings = {prefix: 'test'}
      #     UsersIndex.index_name # => 'test_users'
      #     UsersIndex.index_name(prefix: 'foobar') # => 'foobar_users'
      #     UsersIndex.index_name(suffix: '2017') # => 'test_users_2017'
      #     UsersIndex.index_name(prefix: '', suffix: '2017') # => 'users_2017'
      #
      #   @param prefix [String] index name prefix, uses {.prefix} method by default
      #   @param suffix [String] index name suffix, used for creating several indexes for the same alias during the zero-downtime reset
      #   @raise [UndefinedIndex] if the base name is blank
      #   @return [String] result index name
      def index_name(suggest = nil, prefix: nil, suffix: nil)
        if suggest
          @base_name = suggest.to_s.presence
        else
          [
            prefix || prefix_with_deprecation,
            base_name,
            suffix
          ].reject(&:blank?).join('_')
        end
      end

      # Base name for the index. Uses the default value inferred from the
      # class name unless redefined.
      #
      # @example
      #   class Namespace::UsersIndex < Chewy::Index
      #   end
      #   UsersIndex.index_name # => 'users'
      #
      #   Class.new(Chewy::Index).base_name # => raises UndefinedIndex
      #
      # @raise [UndefinedIndex] when the base name is blank
      # @return [String] current base name
      def base_name
        @base_name ||= name.sub(/Index\z/, '').demodulize.underscore if name
        raise UndefinedIndex if @base_name.blank?
        @base_name
      end

      # Similar to the {.base_name} but respects the class namespace, also,
      # can't be redefined. Used to reference index with the string identifier
      #
      # @example
      #   class Namespace::UsersIndex < Chewy::Index
      #   end
      #   UsersIndex.derivable_name # => 'namespace/users'
      #
      #   Class.new(Chewy::Index).derivable_name # => nil
      #
      # @return [String, nil] derivable name or nil when it is impossible to calculate
      def derivable_name
        @derivable_name ||= name.sub(/Index\z/, '').underscore if name
      end

      # Used as a default value for {.index_name}. Return prefix from the configuration
      # but can be redefined per-index to be more dynamic.
      #
      # @example
      #   class UsersIndex < Chewy::Index
      #     def self.prefix
      #       'foobar'
      #     end
      #   end
      #   UsersIndex.index_name # => 'foobar_users'
      #
      # @return [String] prefix
      def prefix
        Chewy.configuration[:prefix]
      end

      # Defines type for the index. Arguments depends on adapter used. For
      # ActiveRecord you can pass model or scope and options
      #
      #   class CarsIndex < Chewy::Index
      #     define_type Car do
      #       ...
      #     end # defines VehiclesIndex::Car type
      #   end
      #
      # Type name might be passed in complicated cases:
      #
      #   class VehiclesIndex < Chewy::Index
      #     define_type Vehicle.cars.includes(:manufacturer), name: 'cars' do
      #        ...
      #     end # defines VehiclesIndex::Cars type
      #
      #     define_type Vehicle.motocycles.includes(:manufacturer), name: 'motocycles' do
      #        ...
      #     end # defines VehiclesIndex::Motocycles type
      #   end
      #
      # For plain objects:
      #
      #   class PlanesIndex < Chewy::Index
      #     define_type :plane do
      #       ...
      #     end # defines PlanesIndex::Plane type
      #   end
      #
      # The main difference between using plain objects or ActiveRecord models for indexing
      # is import. If you will call `CarsIndex::Car.import` - it will import all the cars
      # automatically, while `PlanesIndex::Plane.import(my_planes)` requires import data to be
      # passed.
      #
      def define_type(target, options = {}, &block)
        type_class = Chewy.create_type(self, target, options, &block)
        self.type_hash = type_hash.merge(type_class.type_name => type_class)
      end

      # Types method has double usage.
      # If no arguments are passed - it returns array of defined types:
      #
      #   UsersIndex.types # => [UsersIndex::Admin, UsersIndex::Manager, UsersIndex::User]
      #
      # If arguments are passed it treats like a part of chainable query DSL and
      # adds types array for index to select.
      #
      #   UsersIndex.filters { name =~ 'ro' }.types(:admin, :manager)
      #   UsersIndex.types(:admin, :manager).filters { name =~ 'ro' } # the same as the first example
      #
      def types(*args)
        if args.present?
          all.types(*args)
        else
          type_hash.values
        end
      end

      # Returns defined types names:
      #
      #   UsersIndex.type_names # => ['admin', 'manager', 'user']
      #
      def type_names
        type_hash.keys
      end

      # Returns named type:
      #
      #    UserIndex.type('admin') # => UsersIndex::Admin
      #
      def type(type_name)
        type_hash.fetch(type_name) { raise UndefinedType, "Unknown type in #{name}: #{type_name}" }
      end

      # Used as a part of index definition DSL. Defines settings:
      #
      #   class UsersIndex < Chewy::Index
      #     settings analysis: {
      #       analyzer: {
      #         name: {
      #           tokenizer: 'standard',
      #           filter: ['lowercase', 'icu_folding', 'names_nysiis']
      #         }
      #       }
      #     }
      #   end
      #
      # See http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-update-settings.html
      # for more details
      #
      # It is possible to store analyzers settings in Chewy repositories
      # and link them form index class. See `Chewy::Index::Settings` for details.
      #
      def settings(params = {}, &block)
        self._settings = Chewy::Index::Settings.new(params, &block)
      end

      # Returns list of public class methods defined in current index
      #
      def scopes
        public_methods - Chewy::Index.public_methods
      end

      def settings_hash
        _settings.to_hash
      end

      def mappings_hash
        mappings = types.map(&:mappings_hash).inject(:merge)
        mappings.present? ? {mappings: mappings} : {}
      end

      # Returns a hash containing the index settings and mappings
      # Used for the ES index creation as body.
      #
      # @see Chewy::Index::Specification
      # @return [Hash] specification as a hash
      def specification_hash
        [settings_hash, mappings_hash].inject(:merge)
      end

      def index_params
        ActiveSupport::Deprecation.warn '`Chewy::Index.index_params` is deprecated and will be removed soon, use `Chewy::Index.specification_hash`'
        specification_hash
      end

      # @see Chewy::Index::Specification
      # @return [Chewy::Index::Specification] a specification object instance for this particular index
      def specification
        @specification ||= Specification.new(self)
      end

      def derivable_index_name
        ActiveSupport::Deprecation.warn '`Chewy::Index.derivable_index_name` is deprecated and will be removed soon, use `Chewy::Index.derivable_name` instead'
        derivable_name
      end

      # Handling old default_prefix if it is not defined.
      def method_missing(name, *args, &block) # rubocop:disable Style/MethodMissing
        if name == :default_prefix
          ActiveSupport::Deprecation.warn '`Chewy::Index.default_prefix` is deprecated and will be removed soon, use `Chewy::Index.prefix` instead'
          prefix
        else
          super
        end
      end

      def prefix_with_deprecation
        if respond_to?(:default_prefix)
          ActiveSupport::Deprecation.warn '`Chewy::Index.default_prefix` is deprecated and will be removed soon, define `Chewy::Index.prefix` method instead'
          default_prefix
        else
          prefix
        end
      end

      def build_index_name(*args)
        ActiveSupport::Deprecation.warn '`Chewy::Index.build_index_name` is deprecated and will be removed soon, use `Chewy::Index.index_name` instead'
        index_name(args.extract_options!)
      end
    end
  end
end
