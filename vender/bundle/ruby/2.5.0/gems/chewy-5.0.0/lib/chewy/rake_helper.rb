module Chewy
  module RakeHelper
    IMPORT_CALLBACK = lambda do |output, _name, start, finish, _id, payload|
      duration = (finish - start).ceil
      stats = payload.fetch(:import, {}).map { |key, count| "#{key} #{count}" }.join(', ')
      output.puts "  Imported #{payload[:type]} in #{human_duration(duration)}, stats: #{stats}"
      if payload[:errors]
        payload[:errors].each do |action, errors|
          output.puts "    #{action.to_s.humanize} errors:"
          errors.each do |error, documents|
            output.puts "      `#{error}`"
            output.puts "        on #{documents.count} documents: #{documents}"
          end
        end
      end
    end

    JOURNAL_CALLBACK = lambda do |output, _, _, _, _, payload|
      count = payload[:groups].values.map(&:size).sum
      targets = payload[:groups].keys.sort_by(&:derivable_name)
      output.puts "  Applying journal to #{targets}, #{count} entries, stage #{payload[:stage]}"
    end

    class << self
      # Performs zero-downtime reindexing of all documents for the specified indexes
      #
      # @example
      #   Chewy::RakeHelper.reset # resets everything
      #   Chewy::RakeHelper.reset(only: 'cities') # resets only CitiesIndex
      #   Chewy::RakeHelper.reset(only: ['cities', CountriesIndex]) # resets CitiesIndex and CountriesIndex
      #   Chewy::RakeHelper.reset(except: CitiesIndex) # resets everything, but CitiesIndex
      #   Chewy::RakeHelper.reset(only: ['cities', 'countries'], except: CitiesIndex) # resets only CountriesIndex
      #
      # @param only [Array<Chewy::Index, String>, Chewy::Index, String] index or indexes to reset; if nothing is passed - uses all the indexes defined in the app
      # @param except [Array<Chewy::Index, String>, Chewy::Index, String] index or indexes to exclude from processing
      # @param parallel [true, Integer, Hash] any acceptable parallel options for import
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Index>] indexes that were reset
      def reset(only: nil, except: nil, parallel: nil, output: STDOUT)
        subscribed_task_stats(output) do
          indexes_from(only: only, except: except).each do |index|
            reset_one(index, output, parallel: parallel)
          end
        end
      end

      # Performs zero-downtime reindexing of all documents for the specified
      # indexes only if a particular index specification was changed.
      #
      # @example
      #   Chewy::RakeHelper.upgrade # resets everything
      #   Chewy::RakeHelper.upgrade(only: 'cities') # resets only CitiesIndex
      #   Chewy::RakeHelper.upgrade(only: ['cities', CountriesIndex]) # resets CitiesIndex and CountriesIndex
      #   Chewy::RakeHelper.upgrade(except: CitiesIndex) # resets everything, but CitiesIndex
      #   Chewy::RakeHelper.upgrade(only: ['cities', 'countries'], except: CitiesIndex) # resets only CountriesIndex
      #
      # @param only [Array<Chewy::Index, String>, Chewy::Index, String] index or indexes to reset; if nothing is passed - uses all the indexes defined in the app
      # @param except [Array<Chewy::Index, String>, Chewy::Index, String] index or indexes to exclude from processing
      # @param parallel [true, Integer, Hash] any acceptable parallel options for import
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Index>] indexes that were actually reset
      def upgrade(only: nil, except: nil, parallel: nil, output: STDOUT)
        subscribed_task_stats(output) do
          indexes = indexes_from(only: only, except: except)

          changed_indexes = indexes.select do |index|
            index.specification.changed?
          end

          if changed_indexes.present?
            indexes.each do |index|
              if changed_indexes.include?(index)
                reset_one(index, output, parallel: parallel)
              else
                output.puts "Skipping #{index}, the specification didn't change"
              end
            end
          else
            output.puts 'No index specification was changed'
          end

          changed_indexes
        end
      end

      # Performs full update for each passed type if the corresponding index exists.
      #
      # @example
      #   Chewy::RakeHelper.update # updates everything
      #   Chewy::RakeHelper.update(only: 'places') # updates only PlacesIndex::City and PlacesIndex::Country
      #   Chewy::RakeHelper.update(only: 'places#city') # updates PlacesIndex::City only
      #   Chewy::RakeHelper.update(except: PlacesIndex::Country) # updates everything, but PlacesIndex::Country
      #   Chewy::RakeHelper.update(only: 'places', except: 'places#country') # updates PlacesIndex::City only
      #
      # @param only [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to update; if nothing is passed - uses all the types defined in the app
      # @param except [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to exclude from processing
      # @param parallel [true, Integer, Hash] any acceptable parallel options for import
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Type>] types that were actually updated
      def update(only: nil, except: nil, parallel: nil, output: STDOUT)
        subscribed_task_stats(output) do
          types_from(only: only, except: except).group_by(&:index).each_with_object([]) do |(index, types), update_types|
            if index.exists?
              output.puts "Updating #{index}"
              types.each { |type| type.import(parallel: parallel) }
              update_types.concat(types)
            else
              output.puts "Skipping #{index}, it does not exists (use rake chewy:reset[#{index.derivable_name}] to create and update it)"
            end
          end
        end
      end

      # Performs synchronization for each passed index if it exists.
      #
      # @example
      #   Chewy::RakeHelper.sync # synchronizes everything
      #   Chewy::RakeHelper.sync(only: 'places') # synchronizes only PlacesIndex::City and PlacesIndex::Country
      #   Chewy::RakeHelper.sync(only: 'places#city') # synchronizes PlacesIndex::City only
      #   Chewy::RakeHelper.sync(except: PlacesIndex::Country) # synchronizes everything, but PlacesIndex::Country
      #   Chewy::RakeHelper.sync(only: 'places', except: 'places#country') # synchronizes PlacesIndex::City only
      #
      # @param only [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to synchronize; if nothing is passed - uses all the types defined in the app
      # @param except [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to exclude from processing
      # @param parallel [true, Integer, Hash] any acceptable parallel options for sync
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Type>] types that were actually updated
      def sync(only: nil, except: nil, parallel: nil, output: STDOUT)
        subscribed_task_stats(output) do
          types_from(only: only, except: except).each_with_object([]) do |type, synced_types|
            output.puts "Synchronizing #{type}"
            output.puts "  #{type} doesn't support outdated synchronization" unless type.supports_outdated_sync?
            time = Time.now
            sync_result = type.sync(parallel: parallel)
            if !sync_result
              output.puts "  Something went wrong with the #{type} synchronization"
            elsif sync_result[:count] > 0
              output.puts "  Missing documents: #{sync_result[:missing]}" if sync_result[:missing].present?
              output.puts "  Outdated documents: #{sync_result[:outdated]}" if sync_result[:outdated].present?
              synced_types.push(type)
            else
              output.puts "  Skipping #{type}, up to date"
            end
            output.puts "  Took #{human_duration(Time.now - time)}"
          end
        end
      end

      # Applies changes that were done after the specified time for the
      # specified indexes/types or all of them.
      #
      # @example
      #   Chewy::RakeHelper.journal_apply(time: 1.minute.ago) # applies entries created for the last minute
      #   Chewy::RakeHelper.journal_apply(time: 1.minute.ago, only: 'places') # applies only PlacesIndex::City and PlacesIndex::Country entries reated for the last minute
      #   Chewy::RakeHelper.journal_apply(time: 1.minute.ago, only: 'places#city') # applies PlacesIndex::City entries reated for the last minute only
      #   Chewy::RakeHelper.journal_apply(time: 1.minute.ago, except: PlacesIndex::Country) # applies everything, but PlacesIndex::Country entries reated for the last minute
      #   Chewy::RakeHelper.journal_apply(time: 1.minute.ago, only: 'places', except: 'places#country') # applies PlacesIndex::City entries reated for the last minute only
      #
      # @param time [Time, DateTime] use only journal entries created after this time
      # @param only [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to synchronize; if nothing is passed - uses all the types defined in the app
      # @param except [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to exclude from processing
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Type>] types that were actually updated
      def journal_apply(time: nil, only: nil, except: nil, output: STDOUT)
        raise ArgumentError, 'Please specify the time to start with' unless time
        subscribed_task_stats(output) do
          output.puts "Applying journal entries created after #{time}"
          count = Chewy::Journal.new(types_from(only: only, except: except)).apply(time)
          output.puts 'No journal entries were created after the specified time' if count.zero?
        end
      end

      # Removes journal records created before the specified timestamp for
      # the specified indexes/types or all of them.
      #
      # @example
      #   Chewy::RakeHelper.journal_clean # cleans everything
      #   Chewy::RakeHelper.journal_clean(time: 1.minute.ago) # leaves only entries created for the last minute
      #   Chewy::RakeHelper.journal_clean(only: 'places') # cleans only PlacesIndex::City and PlacesIndex::Country entries
      #   Chewy::RakeHelper.journal_clean(only: 'places#city') # cleans PlacesIndex::City entries only
      #   Chewy::RakeHelper.journal_clean(except: PlacesIndex::Country) # cleans everything, but PlacesIndex::Country entries
      #   Chewy::RakeHelper.journal_clean(only: 'places', except: 'places#country') # cleans PlacesIndex::City entries only
      #
      # @param time [Time, DateTime] clean all the journal entries created before this time
      # @param only [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to synchronize; if nothing is passed - uses all the types defined in the app
      # @param except [Array<Chewy::Index, Chewy::Type, String>, Chewy::Index, Chewy::Type, String] indexes or types to exclude from processing
      # @param output [IO] output io for logging
      # @return [Array<Chewy::Type>] types that were actually updated
      def journal_clean(time: nil, only: nil, except: nil, output: STDOUT)
        subscribed_task_stats(output) do
          output.puts "Cleaning journal entries created before #{time}" if time
          response = Chewy::Journal.new(types_from(only: only, except: except)).clean(time)
          count = response['deleted'] || response['_indices']['_all']['deleted']
          output.puts "Cleaned up #{count} journal entries"
        end
      end

      # Eager loads and returns all the indexes defined in the application
      # except Chewy::Stash::Specification and Chewy::Stash::Journal.
      #
      # @return [Array<Chewy::Index>] indexes found
      def all_indexes
        Chewy.eager_load!
        Chewy::Index.descendants - [Chewy::Stash::Journal, Chewy::Stash::Specification]
      end

      def normalize_indexes(*identifiers)
        identifiers.flatten(1).map { |identifier| normalize_index(identifier) }
      end

      def normalize_index(identifier)
        return identifier if identifier.is_a?(Class) && identifier < Chewy::Index
        "#{identifier.to_s.gsub(/identifier\z/i, '').camelize}Index".constantize
      end

      def subscribed_task_stats(output = STDOUT)
        start = Time.now
        ActiveSupport::Notifications.subscribed(JOURNAL_CALLBACK.curry[output], 'apply_journal.chewy') do
          ActiveSupport::Notifications.subscribed(IMPORT_CALLBACK.curry[output], 'import_objects.chewy') do
            yield
          end
        end
        output.puts "Total: #{human_duration(Time.now - start)}"
      end

      def reset_index(*indexes)
        ActiveSupport::Deprecation.warn '`Chewy::RakeHelper.reset_index` is deprecated and will be removed soon, use `Chewy::RakeHelper.reset` instead'
        reset(only: indexes)
      end

      def reset_all(*except)
        ActiveSupport::Deprecation.warn '`Chewy::RakeHelper.reset_all` is deprecated and will be removed soon, use `Chewy::RakeHelper.reset` instead'
        reset(except: except)
      end

      def update_index(*indexes)
        ActiveSupport::Deprecation.warn '`Chewy::RakeHelper.update_index` is deprecated and will be removed soon, use `Chewy::RakeHelper.update` instead'
        update(only: indexes)
      end

      def update_all(*except)
        ActiveSupport::Deprecation.warn '`Chewy::RakeHelper.update_all` is deprecated and will be removed soon, use `Chewy::RakeHelper.update` instead'
        update(except: except)
      end

    private

      def indexes_from(only: nil, except: nil)
        indexes = if only.present?
          normalize_indexes(Array.wrap(only))
        else
          all_indexes
        end

        indexes = if except.present?
          indexes - normalize_indexes(Array.wrap(except))
        else
          indexes
        end

        indexes.sort_by(&:derivable_name)
      end

      def types_from(only: nil, except: nil)
        types = if only.present?
          normalize_types(Array.wrap(only))
        else
          all_indexes.flat_map(&:types)
        end

        types = if except.present?
          types - normalize_types(Array.wrap(except))
        else
          types
        end

        types.sort_by(&:derivable_name)
      end

      def normalize_types(*identifiers)
        identifiers.flatten(1).flat_map { |identifier| normalize_type(identifier) }
      end

      def normalize_type(identifier)
        Chewy.derive_types(identifier)
      end

      def human_duration(seconds)
        [[60, :s], [60, :m], [24, :h]].map do |amount, unit|
          if seconds > 0
            seconds, n = seconds.divmod(amount)
            "#{n.to_i}#{unit}"
          end
        end.compact.reverse.join(' ')
      end

      def reset_one(index, output, parallel: false)
        output.puts "Resetting #{index}"
        index.reset!((Time.now.to_f * 1000).round, parallel: parallel)
      end
    end
  end
end
