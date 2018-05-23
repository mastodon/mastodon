require 'active_support'
require 'active_support/core_ext/enumerable' # For Enumerable#index_by

class GlobalID
  module Locator
    class << self
      # Takes either a GlobalID or a string that can be turned into a GlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate(gid, options = {})
        if gid = GlobalID.parse(gid)
          locator_for(gid).locate gid if find_allowed?(gid.model_class, options[:only])
        end
      end

      # Takes an array of GlobalIDs or strings that can be turned into a GlobalIDs.
      # All GlobalIDs must belong to the same app, as they will be located using
      # the same locator using its locate_many method.
      #
      # By default the GlobalIDs will be located using Model.find(array_of_ids), so the
      # models must respond to that finder signature.
      #
      # This approach will efficiently call only one #find (or #where(id: id), when using ignore_missing)
      # per model class, but still interpolate the results to match the order in which the gids were passed.
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      # * <tt>:ignore_missing</tt> - By default, locate_many will call #find on the model to locate the
      #   ids extracted from the GIDs. In Active Record (and other data stores following the same pattern),
      #   #find will raise an exception if a named ID can't be found. When you set this option to true,
      #   we will use #where(id: ids) instead, which does not raise on missing records.
      def locate_many(gids, options = {})
        if (allowed_gids = parse_allowed(gids, options[:only])).any?
          locator = locator_for(allowed_gids.first)
          locator.locate_many(allowed_gids, options)
        else
          []
        end
      end

      # Takes either a SignedGlobalID or a string that can be turned into a SignedGlobalID
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate_signed(sgid, options = {})
        SignedGlobalID.find sgid, options
      end

      # Takes an array of SignedGlobalIDs or strings that can be turned into a SignedGlobalIDs.
      # The SignedGlobalIDs are located using Model.find(array_of_ids), so the models must respond to
      # that finder signature.
      #
      # This approach will efficiently call only one #find per model class, but still interpolate
      # the results to match the order in which the gids were passed.
      #
      # Options:
      # * <tt>:only</tt> - A class, module or Array of classes and/or modules that are
      #   allowed to be located.  Passing one or more classes limits instances of returned
      #   classes to those classes or their subclasses.  Passing one or more modules in limits
      #   instances of returned classes to those including that module.  If no classes or
      #   modules match, +nil+ is returned.
      def locate_many_signed(sgids, options = {})
        locate_many sgids.collect { |sgid| SignedGlobalID.parse(sgid, options.slice(:for)) }.compact, options
      end

      # Tie a locator to an app.
      # Useful when different apps collaborate and reference each others' Global IDs.
      #
      # The locator can be either a block or a class.
      #
      # Using a block:
      #
      #   GlobalID::Locator.use :foo do |gid|
      #     FooRemote.const_get(gid.model_name).find(gid.model_id)
      #   end
      #
      # Using a class:
      #
      #   GlobalID::Locator.use :bar, BarLocator.new
      #
      #   class BarLocator
      #     def locate(gid)
      #       @search_client.search name: gid.model_name, id: gid.model_id
      #     end
      #   end
      def use(app, locator = nil, &locator_block)
        raise ArgumentError, 'No locator provided. Pass a block or an object that responds to #locate.' unless locator || block_given?

        URI::GID.validate_app(app)

        @locators[normalize_app(app)] = locator || BlockLocator.new(locator_block)
      end

      private
        def locator_for(gid)
          @locators.fetch(normalize_app(gid.app)) { DEFAULT_LOCATOR }
        end

        def find_allowed?(model_class, only = nil)
          only ? Array(only).any? { |c| model_class <= c } : true
        end

        def parse_allowed(gids, only = nil)
          gids.collect { |gid| GlobalID.parse(gid) }.compact.select { |gid| find_allowed?(gid.model_class, only) }
        end

        def normalize_app(app)
          app.to_s.downcase
        end
    end

    private
      @locators = {}

      class BaseLocator
        def locate(gid)
          gid.model_class.find gid.model_id
        end

        def locate_many(gids, options = {})
          models_and_ids  = gids.collect { |gid| [ gid.model_class, gid.model_id ] }
          ids_by_model    = models_and_ids.group_by(&:first)
          loaded_by_model = Hash[ids_by_model.map { |model, ids|
            [ model, find_records(model, ids.map(&:last), ignore_missing: options[:ignore_missing]).index_by { |record| record.id.to_s } ]
          }]

          models_and_ids.collect { |(model, id)| loaded_by_model[model][id] }.compact
        end

        private
          def find_records(model_class, ids, options)
            if options[:ignore_missing]
              model_class.where(id: ids)
            else
              model_class.find(ids)
            end
          end
      end

      class UnscopedLocator < BaseLocator
        def locate(gid)
          unscoped(gid.model_class) { super }
        end

        private
          def find_records(model_class, ids, options)
            unscoped(model_class) { super }
          end

          def unscoped(model_class)
            if model_class.respond_to?(:unscoped)
              model_class.unscoped { yield }
            else
              yield
            end
          end
      end
      DEFAULT_LOCATOR = UnscopedLocator.new

      class BlockLocator
        def initialize(block)
          @locator = block
        end

        def locate(gid)
          @locator.call(gid)
        end

        def locate_many(gids, options = {})
          gids.map { |gid| locate(gid) }
        end
      end
  end
end
