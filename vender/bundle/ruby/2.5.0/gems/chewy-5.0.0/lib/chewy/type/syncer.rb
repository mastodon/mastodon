module Chewy
  class Type
    # This class is able to find missing and outdated documents in the ES
    # comparing ids from the data source and the ES index. Also, if `outdated_sync_field`
    # existss in the index definition, it performs comparison of this field
    # values for each source object and corresponding ES document. Usually,
    # this field is `updated_at` and if its value in the source is not equal
    # to the value in the index - this means that this document outdated and
    # should be reindexed.
    #
    # To fetch necessary data from the source it uses adapter method
    # {Chewy::Type::Adapter::Base#import_fields}, in case when the Object
    # adapter is used it makes sense to read corresponding documentation.
    #
    # If `parallel` option is passed to the initializer - it will fetch surce and
    # index data in parallel and then perform outdated objects calculation in
    # parallel processes. Also, further import (if required) will be performed
    # in parallel as well.
    #
    # @note
    #   In rails 4.0 time converted to json with the precision of seconds
    #   without milliseconds used, so outdated check is not so precise there.
    #
    #   ATTENTION: synchronization may be slow in case when synchronized tables
    #   are missing compound index on primary key and `outdated_sync_field`.
    #
    # @see Chewy::Type::Actions::ClassMethods#sync
    class Syncer
      DEFAULT_SYNC_BATCH_SIZE = 20_000
      ISO_DATETIME = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?\z/
      OUTDATED_IDS_WORKER = lambda do |outdated_sync_field_type, source_data_hash, type, total, index_data|
        ::Process.setproctitle("chewy [#{type}]: sync outdated calculation (#{::Parallel.worker_number + 1}/#{total})") if type
        index_data.each_with_object([]) do |(id, index_sync_value), result|
          next unless source_data_hash[id]

          outdated = if outdated_sync_field_type == 'date'
            !Chewy::Type::Syncer.dates_equal(typecast_date(source_data_hash[id]), Time.iso8601(index_sync_value))
          else
            source_data_hash[id] != index_sync_value
          end

          result.push(id) if outdated
        end
      end
      SOURCE_OR_INDEX_DATA_WORKER = lambda do |syncer, type, kind|
        ::Process.setproctitle("chewy [#{type}]: sync fetching data (#{kind})")
        result = case kind
        when :source
          syncer.send(:fetch_source_data)
        when :index
          syncer.send(:fetch_index_data)
        end
        {kind => result}
      end

      def self.typecast_date(string)
        if string.is_a?(String) && (match = ISO_DATETIME.match(string))
          microsec = (match[7].to_r * 1_000_000).to_i
          date = "#{match[1]}-#{match[2]}-#{match[3]}T#{match[4]}:#{match[5]}:#{match[6]}.#{format('%06d', microsec)}+00:00"
          Time.iso8601(date)
        else
          string
        end
      end

      # Compares times with ms precision.
      def self.dates_equal(one, two)
        [one.to_i, one.usec / 1000] == [two.to_i, two.usec / 1000]
      end

      # In ActiveSupport ~> 4.0 json dumpled times without any
      # milliseconds, so ES stored time with the seconds precision.
      if ActiveSupport::VERSION::STRING < '4.1.0'
        def self.dates_equal(one, two)
          one.to_i == two.to_i
        end
      end

      # @param type [Chewy::Type] chewy type
      # @param parallel [true, Integer, Hash] options for parallel execution or the number of processes
      def initialize(type, parallel: nil)
        @type = type
        @parallel = if !parallel || parallel.is_a?(Hash)
          parallel
        elsif parallel.is_a?(Integer)
          {in_processes: parallel}
        else
          {}
        end
      end

      # Finds all the missing and outdated ids and performs import for them.
      #
      # @return [Integer, nil] the amount of missing and outdated documents reindexed, nil in case of errors
      def perform
        ids = missing_ids | outdated_ids
        return 0 if ids.blank?
        @type.import(ids, parallel: @parallel) && ids.count
      end

      # Finds ids of all the objects that are not indexed yet or deleted
      # from the source already.
      #
      # @return [Array<String>] an array of missing ids from both sides
      def missing_ids
        return [] if source_data.blank?

        @missing_ids ||= begin
          source_data_ids = data_ids(source_data)
          index_data_ids = data_ids(index_data)

          (source_data_ids - index_data_ids).concat(index_data_ids - source_data_ids)
        end
      end

      # If type supports outdated sync, it compares for the values of the
      # type `outdated_sync_field` for each object and document in the source
      # and index and returns the ids of entities which which are having
      # different values there.
      #
      # @see Chewy::Type::Mapping::ClassMethods#supports_outdated_sync?
      # @return [Array<String>] an array of outdated ids
      def outdated_ids
        return [] if source_data.blank? || index_data.blank? || !@type.supports_outdated_sync?
        @outdated_ids ||= begin
          if @parallel
            parallel_outdated_ids
          else
            linear_outdated_ids
          end
        end
      end

    private

      def source_data
        @source_data ||= source_and_index_data.first
      end

      def index_data
        @index_data ||= source_and_index_data.second
      end

      def source_and_index_data
        @source_and_index_data ||= begin
          if @parallel
            ::ActiveRecord::Base.connection.close if defined?(::ActiveRecord::Base)
            result = ::Parallel.map(%i[source index], @parallel, &SOURCE_OR_INDEX_DATA_WORKER.curry[self, @type])
            ::ActiveRecord::Base.connection.reconnect! if defined?(::ActiveRecord::Base)
            if result.first.keys.first == :source
              [result.first.values.first, result.second.values.first]
            else
              [result.second.values.first, result.first.values.first]
            end
          else
            [fetch_source_data, fetch_index_data]
          end
        end
      end

      def fetch_source_data
        if @type.supports_outdated_sync?
          @type.adapter.import_fields(fields: [@type.outdated_sync_field], batch_size: DEFAULT_SYNC_BATCH_SIZE, typecast: false).to_a.flatten(1).each do |data|
            data[0] = data[0].to_s
          end
        else
          @type.adapter.import_fields(batch_size: DEFAULT_SYNC_BATCH_SIZE, typecast: false).to_a.flatten(1).map(&:to_s)
        end
      end

      def fetch_index_data
        if @type.supports_outdated_sync?
          @type.pluck(:_id, @type.outdated_sync_field).each do |data|
            data[0] = data[0].to_s
          end
        else
          @type.pluck(:_id).map(&:to_s)
        end
      end

      def data_ids(data)
        return data unless @type.supports_outdated_sync?
        data.map(&:first)
      end

      def linear_outdated_ids
        OUTDATED_IDS_WORKER.call(outdated_sync_field_type, source_data.to_h, nil, nil, index_data)
      end

      def parallel_outdated_ids
        size = processor_count.zero? ? index_data.size : (index_data.size / processor_count.to_f).ceil
        batches = index_data.each_slice(size)

        ::ActiveRecord::Base.connection.close if defined?(::ActiveRecord::Base)
        result = ::Parallel.map(batches, @parallel, &OUTDATED_IDS_WORKER.curry[outdated_sync_field_type, source_data.to_h, @type, batches.size]).flatten(1)
        ::ActiveRecord::Base.connection.reconnect! if defined?(::ActiveRecord::Base)
        result
      end

      def processor_count
        @processor_count ||= @parallel[:in_processes] || @parallel[:in_threads] || ::Parallel.processor_count
      end

      def outdated_sync_field_type
        return @outdated_sync_field_type if instance_variable_defined?(:@outdated_sync_field_type)
        return unless @type.outdated_sync_field

        mappings = @type.client.indices.get_mapping(
          index: @type.index_name,
          type: @type.type_name
        ).values.first.fetch('mappings', {})

        @outdated_sync_field_type = mappings
          .fetch(@type.type_name, {})
          .fetch('properties', {})
          .fetch(@type.outdated_sync_field.to_s, {})['type']
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        nil
      end
    end
  end
end
