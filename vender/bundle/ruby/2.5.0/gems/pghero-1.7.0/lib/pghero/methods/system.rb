module PgHero
  module Methods
    module System
      def cpu_usage(options = {})
        rds_stats("CPUUtilization", options)
      end

      def connection_stats(options = {})
        rds_stats("DatabaseConnections", options)
      end

      def replication_lag_stats(options = {})
        rds_stats("ReplicaLag", options)
      end

      def read_iops_stats(options = {})
        rds_stats("ReadIOPS", options)
      end

      def write_iops_stats(options = {})
        rds_stats("WriteIOPS", options)
      end

      def rds_stats(metric_name, options = {})
        if system_stats_enabled?
          aws_options = {region: region}
          if access_key_id
            aws_options[:access_key_id] = access_key_id
            aws_options[:secret_access_key] = secret_access_key
          end

          client =
            if defined?(Aws)
              Aws::CloudWatch::Client.new(aws_options)
            else
              AWS::CloudWatch.new(aws_options).client
            end

          duration = (options[:duration] || 1.hour).to_i
          period = (options[:period] || 1.minute).to_i
          offset = (options[:offset] || 0).to_i

          end_time = (Time.now - offset)
          # ceil period
          end_time = Time.at((end_time.to_f / period).ceil * period)

          resp = client.get_metric_statistics(
            namespace: "AWS/RDS",
            metric_name: metric_name,
            dimensions: [{name: "DBInstanceIdentifier", value: db_instance_identifier}],
            start_time: (end_time - duration).iso8601,
            end_time: end_time.iso8601,
            period: period,
            statistics: ["Average"]
          )
          data = {}
          resp[:datapoints].sort_by { |d| d[:timestamp] }.each do |d|
            data[d[:timestamp]] = d[:average]
          end
          data
        else
          {}
        end
      end

      def system_stats_enabled?
        !!((defined?(Aws) || defined?(AWS)) && db_instance_identifier)
      end

      def access_key_id
        ENV["PGHERO_ACCESS_KEY_ID"] || ENV["AWS_ACCESS_KEY_ID"]
      end

      def secret_access_key
        ENV["PGHERO_SECRET_ACCESS_KEY"] || ENV["AWS_SECRET_ACCESS_KEY"]
      end

      def region
        ENV["PGHERO_REGION"] || ENV["AWS_REGION"] || (defined?(Aws) && Aws.config[:region]) || "us-east-1"
      end

      def db_instance_identifier
        databases[current_database].db_instance_identifier
      end
    end
  end
end
