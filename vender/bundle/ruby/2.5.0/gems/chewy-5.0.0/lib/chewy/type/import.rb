require 'chewy/type/import/journal_builder'
require 'chewy/type/import/bulk_builder'
require 'chewy/type/import/bulk_request'
require 'chewy/type/import/routine'

module Chewy
  class Type
    module Import
      extend ActiveSupport::Concern

      IMPORT_WORKER = lambda do |type, options, total, ids, index|
        ::Process.setproctitle("chewy [#{type}]: import data (#{index + 1}/#{total})")
        routine = Routine.new(type, options)
        type.adapter.import(*ids, routine.options) do |action_objects|
          routine.process(**action_objects)
        end
        {errors: routine.errors, import: routine.stats, leftovers: routine.leftovers}
      end

      LEFTOVERS_WORKER = lambda do |type, options, total, body, index|
        ::Process.setproctitle("chewy [#{type}]: import leftovers (#{index + 1}/#{total})")
        routine = Routine.new(type, options)
        routine.perform_bulk(body)
        routine.errors
      end

      module ClassMethods
        # @!method import(*collection, **options)
        # Basically, one of the main methods for type. Performs any objects import
        # to the index for a specified type. Does all the objects handling routines.
        # Performs document import by utilizing bulk API. Bulk size and objects batch
        # size are controlled by the corresponding options.
        #
        # It accepts ORM/ODM objects, PORO, hashes, ids which are used by adapter to
        # fetch objects from the source depenting on the used adapter. It destroys
        # passed objects from the index if they are not in the default type scope
        # or marked for destruction.
        #
        # It handles parent-child relationships: if the object parent_id has been
        # changed it destroys the object and recreates it from scratch.
        #
        # Performs journaling if enabled: it stores all the ids of the imported
        # objects to a specialized index. It is possible to replay particular import
        # later to restore the data consistency.
        #
        # Performs partial index update using `update` bulk action if any `fields` are
        # specified. Note that if document doesn't exist yet, an error will be raised
        # by ES, but import catches this an errors and performs full indexing
        # for the corresponding documents. This feature can be disabled by setting
        # `update_failover` to `false`.
        #
        # Utilizes `ActiveSupport::Notifications`, so it is possible to get imported
        # objects later by listening to the `import_objects.chewy` queue. It is also
        # possible to get the list of occured errors from the payload if something
        # went wrong.
        #
        # Import can also be run in parallel using the Parallel gem functionality.
        #
        # @example
        #   UsersIndex::User.import(parallel: true) # imports everything in parallel with automatic workers number
        #   UsersIndex::User.import(parallel: 3) # using 3 workers
        #   UsersIndex::User.import(parallel: {in_threads: 10}) # in 10 threads
        #
        # @see https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/bulk.rb
        # @param collection [Array<Object>] and array or anything to import
        # @param options [Hash{Symbol => Object}] besides specific import options, it accepts all the options suitable for the bulk API call like `refresh` or `timeout`
        # @option options [String] suffix an index name suffix, used for zero-downtime reset mostly, no suffix by default
        # @option options [Integer] bulk_size bulk API chunk size in bytes; if passed, the request is performed several times for each chunk, empty by default
        # @option options [Integer] batch_size passed to the adapter import method, used to split imported objects in chunks, 1000 by default
        # @option options [true, false] journal enables imported objects journaling, false by default
        # @option options [Array<Symbol, String>] update_fields list of fields for the partial import, empty by default
        # @option options [true, false] update_failover enables full objects reimport in cases of partial update errors, `true` by default
        # @option options [true, Integer, Hash] parallel enables parallel import processing with the Parallel gem, accepts the number of workers or any Parallel gem acceptable options
        # @return [true, false] false in case of errors
        def import(*args)
          import_routine(*args).blank?
        end

        # @!method import!(*collection, **options)
        # (see #import)
        #
        # The only difference from {#import} is that it raises an exception
        # in case of any import errors.
        #
        # @raise [Chewy::ImportFailed] in case of errors
        def import!(*args)
          errors = import_routine(*args)
          raise Chewy::ImportFailed.new(self, errors) if errors.present?
          true
        end

        # Wraps elasticsearch API bulk method, adds additional features like
        # `bulk_size` and `suffix`.
        #
        # @see https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/bulk.rb
        # @see Chewy::Type::Import::Bulk
        # @param options [Hash{Symbol => Object}] besides specific import options, it accepts all the options suitable for the bulk API call like `refresh` or `timeout`
        # @option options [String] suffix bulk API chunk size in bytes; if passed, the request is performed several times for each chunk, empty by default
        # @option options [Integer] bulk_size bulk API chunk size in bytes; if passed, the request is performed several times for each chunk, empty by default
        # @option options [Array<Hash>] body elasticsearch API bulk method body
        # @return [Hash] tricky transposed errors hash, empty if everything is fine
        def bulk(**options)
          error_items = BulkRequest.new(self, **options).perform(options[:body])
          Chewy.wait_for_status

          payload_errors(error_items)
        end

        # Composes a single document from the passed object. Uses either witchcraft
        # or normal composing under the hood.
        #
        # @param object [Object] a data source object
        # @param crutches [Object] optional crutches object; if ommited - a crutch for the single passed object is created as a fallback
        # @param fields [Array<Symbol>] and array of fields to restrict the generated document
        # @return [Hash] a JSON-ready hash
        def compose(object, crutches = nil, fields: [])
          crutches ||= Chewy::Type::Crutch::Crutches.new self, [object]

          if witchcraft? && root.children.present?
            cauldron(fields: fields).brew(object, crutches)
          else
            root.compose(object, crutches, fields: fields)
          end
        end

      private

        def import_routine(*args)
          return if args.first.blank? && !args.first.nil?
          routine = Routine.new(self, args.extract_options!)
          routine.create_indexes!

          if routine.parallel_options
            import_parallel(args, routine)
          else
            import_linear(args, routine)
          end
        end

        def import_linear(objects, routine)
          ActiveSupport::Notifications.instrument 'import_objects.chewy', type: self do |payload|
            adapter.import(*objects, routine.options) do |action_objects|
              routine.process(**action_objects)
            end
            routine.perform_bulk(routine.leftovers)
            payload[:import] = routine.stats
            payload[:errors] = payload_errors(routine.errors) if routine.errors.present?
            payload[:errors]
          end
        end

        def import_parallel(objects, routine)
          raise "The `parallel` gem is required for parallel import, please add `gem 'parallel'` to your Gemfile" unless '::Parallel'.safe_constantize

          ActiveSupport::Notifications.instrument 'import_objects.chewy', type: self do |payload|
            batches = adapter.import_references(*objects, routine.options.slice(:batch_size)).to_a

            ::ActiveRecord::Base.connection.close if defined?(::ActiveRecord::Base)
            results = ::Parallel.map_with_index(batches, routine.parallel_options, &IMPORT_WORKER.curry[self, routine.options, batches.size])
            ::ActiveRecord::Base.connection.reconnect! if defined?(::ActiveRecord::Base)
            errors, import, leftovers = process_parallel_import_results(results)

            if leftovers.present?
              batches = leftovers.each_slice(routine.options[:batch_size])
              results = ::Parallel.map_with_index(batches, routine.parallel_options, &LEFTOVERS_WORKER.curry[self, routine.options, batches.size])
              errors.concat(results.flatten(1))
            end

            payload[:import] = import
            payload[:errors] = payload_errors(errors) if errors.present?
            payload[:errors]
          end
        end

        def process_parallel_import_results(results)
          results.each_with_object([[], {}, []]) do |r, (e, i, l)|
            e.concat(r[:errors])
            i.merge!(r[:import]) { |_k, v1, v2| v1.to_i + v2.to_i }
            l.concat(r[:leftovers])
          end
        end

        def payload_errors(errors)
          errors.each_with_object({}) do |error, result|
            action = error.keys.first.to_sym
            item = error.values.first
            error = item['error']
            id = item['_id']

            result[action] ||= {}
            result[action][error] ||= []
            result[action][error].push(id)
          end
        end
      end
    end
  end
end
