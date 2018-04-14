require 'benchmark/ips'
require 'json'

# Add benchmarking runner from ruby-bench-suite
# https://github.com/ruby-bench/ruby-bench-suite/blob/master/rails/benchmarks/support/benchmark_rails.rb
module Benchmark
  module ActiveModelSerializers
    module TestMethods
      def request(method, path)
        response = Rack::MockRequest.new(BenchmarkApp).send(method, path)
        if response.status.in?([404, 500])
          fail "omg, #{method}, #{path}, '#{response.status}', '#{response.body}'"
        end
        response
      end
    end

    # extend Benchmark with an `ams` method
    def ams(label = nil, time:, disable_gc: true, warmup: 3, &block)
      fail ArgumentError.new, 'block should be passed' unless block_given?

      if disable_gc
        GC.disable
      else
        GC.enable
      end

      report = Benchmark.ips(time, warmup, true) do |x|
        x.report(label) { yield }
      end

      entry = report.entries.first

      output = {
        label: label,
        version: ::ActiveModel::Serializer::VERSION.to_s,
        rails_version: ::Rails.version.to_s,
        iterations_per_second: entry.ips,
        iterations_per_second_standard_deviation: entry.error_percentage,
        total_allocated_objects_per_iteration: count_total_allocated_objects(&block)
      }.to_json

      puts output
      output
    end

    def count_total_allocated_objects
      if block_given?
        key =
          if RUBY_VERSION < '2.2'
            :total_allocated_object
          else
            :total_allocated_objects
          end

        before = GC.stat[key]
        yield
        after = GC.stat[key]
        after - before
      else
        -1
      end
    end
  end

  extend Benchmark::ActiveModelSerializers
end
