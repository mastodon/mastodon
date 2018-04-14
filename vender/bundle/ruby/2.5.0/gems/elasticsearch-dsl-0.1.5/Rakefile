require "bundler/gem_tasks"

task(:default) { system "rake --tasks" }
task  :test    => 'test:unit'

# ----- Test tasks ------------------------------------------------------------

require 'rake/testtask'
namespace :test do

  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/unit/**/*_test.rb"]
    test.verbose = false
    test.warning = false
  end

  Rake::TestTask.new(:integration) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/integration/**/*_test.rb"]
    test.verbose = false
    test.warning = false
  end

  desc "Run unit and integration tests"
  task :all do
    Rake::Task['test:unit'].invoke
    Rake::Task['test:integration'].invoke
  end

  namespace :cluster do
    desc "Start Elasticsearch nodes for tests"
    task :start do
      $LOAD_PATH << File.expand_path('../../elasticsearch-transport/lib', __FILE__) << File.expand_path('../test', __FILE__)
      require 'elasticsearch/extensions/test/cluster'
      Elasticsearch::Extensions::Test::Cluster.start
    end

    desc "Stop Elasticsearch nodes for tests"
    task :stop do
      $LOAD_PATH << File.expand_path('../../elasticsearch-transport/lib', __FILE__) << File.expand_path('../test', __FILE__)
      require 'elasticsearch/extensions/test/cluster'
      Elasticsearch::Extensions::Test::Cluster.stop
    end
  end
end

# ----- Documentation tasks ---------------------------------------------------

require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = %w| --embed-mixins --markup=markdown |
end

# ----- Code analysis tasks ---------------------------------------------------

require 'cane/rake_task'
Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 15
  cane.no_style = true
end

# ----- Generating the source code --------------------------------------------

require 'net/http'
require 'json'
require 'coderay'

namespace :generate do
  desc <<-DESC.gsub(/^    /, '')
    Generate Ruby source and tests for query/filter/aggregation

    Pass the type of the component, the name, and any option methods as Rake task arguments.

    Example:

        $ rake generate:source[query,boosting]
        Source: /.../elasticsearch-ruby/elasticsearch-dsl/lib/elasticsearch/dsl/search/queries/boosting.rb
        ...
        Test: /.../elasticsearch-ruby/elasticsearch-dsl/test/unit/queries/boosting_test.rb
        ...

        $ rake generate:source[query,common,query/cutoff_frequency/low_freq_operator/...]
        Source: /.../elasticsearch-ruby/elasticsearch-dsl/lib/elasticsearch/dsl/search/queries/common.rb
        ...
        Test: /.../elasticsearch-ruby/elasticsearch-dsl/test/unit/queries/common_test.rb
        ...

  DESC
  task :source, [:type, :name, :option_methods] do |task, options|
    begin
      query    = URI.escape("#{options[:name]} #{options[:type]}")
      response = Net::HTTP.get('search.elasticsearch.org', "/search/?q=#{query}")
      hits     = JSON.load(response)['hits']['hits']

      if hit = hits.first
        doc_url = ("http://elasticsearch.org" + hit['fields']['url']).gsub(/#.+$/, '') if hit['_score'] > 0.2
      end
    rescue Exception => e
      puts "[!] ERROR: #{e.inspect}"
    end unless ENV['NOCRAWL']

    case options[:type]
      when /query/
        module_name = 'Queries'
        path_name   = 'queries'
        include_module = 'BaseComponent'
      when /filter/
        module_name = 'Filters'
        path_name   = 'filters'
        include_module = 'BaseComponent'
      when /agg/
        module_name = 'Aggregations'
        path_name   = 'aggregations'
        include_module = 'BaseAggregationComponent'
      else raise ArgumentError, "Unknown DSL type [#{options[:type]}]"
    end

    name = options[:name].downcase

    class_name = options[:name].split('_').map(&:capitalize).join

    option_methods = options[:option_methods].to_s.split('/').reduce('') do |sum, item|
      sum << "                "
      sum << "option_method :#{item}"
      sum << "\n" unless item == options[:option_methods].to_s.split('/').last
      sum
    end

    option_methods = "\n\n#{option_methods}" unless option_methods.empty?

    source = <<-RUBY.gsub(/^      /, '')
      module Elasticsearch
        module DSL
          module Search
            module #{module_name}

              # #{class_name} #{options[:type]}
              #
              # @example
              #
              # @see #{doc_url}
              #
              class #{class_name}
                include #{include_module}#{option_methods}
              end

            end
          end
        end
      end
    RUBY

    if options[:option_methods].to_s.empty?
      test_option_methods = ''
    else
      setup = "\n" + options[:option_methods].to_s.split('/').reduce('') do |sum,item|
        sum << "          subject.#{item} 'bar'\n"; sum
      end
      asserts = "\n          assert_equal %w[ #{options[:option_methods].to_s.split('/').sort.join(' ')} ],\n                       subject.to_hash[:#{name}][:foo].keys.map(&:to_s).sort"
      asserts << "\n          assert_equal 'bar', subject.to_hash[:#{name}][:foo][:#{options[:option_methods].to_s.split('/').first}]"

      test_option_methods =  <<-RUBY.gsub(/^        /, '')

        should "have option methods" do
          subject = #{class_name}.new :foo
          #{setup}#{asserts}
        end

        should "take a block" do
          subject = #{class_name}.new :foo do
            #{options[:option_methods].to_s.split('/').first} 'bar'
          end
          assert_equal({#{name}: { foo: { #{options[:option_methods].to_s.split('/').first}: 'bar' } }}, subject.to_hash)
        end
      RUBY
    end

    test = <<-RUBY.gsub(/^      /, '')
      require 'test_helper'

      module Elasticsearch
        module Test
          module #{module_name}
            class #{class_name}Test < ::Test::Unit::TestCase
              include Elasticsearch::DSL::Search::#{module_name}

              context "#{class_name} #{options[:type]}" do
                subject { #{class_name}.new }

                should "be converted to a Hash" do
                  assert_equal({ #{name}: {} }, subject.to_hash)
                end
                #{test_option_methods.empty? ? '' : test_option_methods.split("\n").map { |l| '                ' + l }.join("\n")}
              end
            end
          end
        end
      end
    RUBY

    source_full_path = File.expand_path("../lib/elasticsearch/dsl/search/#{path_name}/#{name}.rb", __FILE__)
    test_full_path   = File.expand_path("../test/unit/#{path_name}/#{name}_test.rb", __FILE__)

    puts '-'*80, "Source: #{source_full_path}", '-'*80, "\n", CodeRay.scan(source, :ruby).terminal, "\n\n"
    puts '-'*80, "Test: #{test_full_path}",     '-'*80, "\n", CodeRay.scan(test,   :ruby).terminal, "\n"

    File.open(source_full_path, 'w') { |file| file << source }

    File.open(test_full_path, 'w') { |file| file << test }
  end
end
