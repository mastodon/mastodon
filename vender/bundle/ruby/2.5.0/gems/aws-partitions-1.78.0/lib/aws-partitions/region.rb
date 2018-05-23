require 'set'

module Aws
  module Partitions
    class Region

      # @option options [required, String] :name
      # @option options [required, String] :description
      # @option options [required, String] :partition_name
      # @option options [required, Set<String>] :services
      # @api private
      def initialize(options = {})
        @name = options[:name]
        @description = options[:description]
        @partition_name = options[:partition_name]
        @services = options[:services]
      end

      # @return [String] The name of this region, e.g. "us-east-1".
      attr_reader :name

      # @return [String] A short description of this region.
      attr_reader :description

      # @return [String] The partition this region exists in, e.g. "aws",
      #   "aws-cn", "aws-us-gov".
      attr_reader :partition_name

      # @return [Set<String>] The list of services available in this region.
      #   Service names are the module names as used by the AWS SDK
      #   for Ruby.
      attr_reader :services

      class << self

        # @api private
        def build(region_name, region, partition)
          Region.new(
            name: region_name,
            description: region['description'],
            partition_name: partition['partition'],
            services: region_services(region_name, partition)
          )
        end

        private

        def region_services(region_name, partition)
          Partitions.service_ids.inject(Set.new) do |services, (svc_name, svc_id)|
            if svc = partition['services'][svc_id]
              services << svc_name if service_in_region?(svc, region_name)
            else
              #raise "missing endpoints for #{svc_name} / #{svc_id}"
            end
            services
          end
        end

        def service_in_region?(svc, region_name)
          svc.key?('endpoints') && svc['endpoints'].key?(region_name)
        end

      end
    end
  end
end
