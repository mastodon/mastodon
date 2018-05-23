module Aws
  module Partitions
    class PartitionList

      include Enumerable

      def initialize
        @partitions = {}
      end

      # @return [Enumerator<Partition>]
      def each(&block)
        @partitions.each_value(&block)
      end

      # @param [String] partition_name
      # @return [Partition]
      def partition(partition_name)
        if @partitions.key?(partition_name)
          @partitions[partition_name]
        else
          msg = "invalid partition name #{partition_name.inspect}; valid "
          msg << "partition names include %s" % [@partitions.keys.join(', ')]
          raise ArgumentError, msg
        end
      end

      # @return [Array<Partition>]
      def partitions
        @partitions.values
      end

      # @param [Partition] partition
      # @api private
      def add_partition(partition)
        if Partition === partition
          @partitions[partition.name] = partition
        else
          raise ArgumentError, "expected Partition, got #{partition.class}"
        end
      end

      # Removed all partitions.
      # @api private
      def clear
        @partitions = {}
      end

      class << self

        # @api private
        def build(partitions)
          partitions['partitions'].inject(PartitionList.new) do |list, partition|
            list.add_partition(Partition.build(partition))
            list
          end
        end

      end
    end
  end
end
