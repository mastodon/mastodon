RUBY_1_8 = defined?(RUBY_VERSION) && RUBY_VERSION < '1.9'
JRUBY    = defined?(JRUBY_VERSION)

require 'pathname'
require 'logger'
require 'yaml'
require 'active_support/inflector'
require 'ansi'
require 'turn'

require 'elasticsearch'
require 'elasticsearch/extensions/test/cluster'
require 'elasticsearch/extensions/test/startup_shutdown'
require 'elasticsearch/extensions/test/profiling' unless JRUBY

# Skip features
skip_features = 'stash_in_path,requires_replica,headers,warnings'
SKIP_FEATURES = ENV.fetch('TEST_SKIP_FEATURES', skip_features)

# Turn configuration
ENV['ansi'] = 'false' if ENV['CI']
Turn.config.format = :pretty

# Launch test cluster
#
if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?
  Elasticsearch::Extensions::Test::Cluster.start
end

# Register `at_exit` handler for server shutdown.
# MUST be called before requiring `test/unit`.
#
at_exit { Elasticsearch::Extensions::Test::Cluster.stop if ENV['SERVER'] and Elasticsearch::Extensions::Test::Cluster.running? }

class String
  # Reset the `ansi` method on CI
  def ansi(*args)
    self
  end
end if ENV['CI']

module CapturedLogger
  def self.included base
    base.class_eval do
      %w[ info error warn fatal debug ].each do |m|
        alias_method "#{m}_without_capture", m

        define_method m do |*args|
          @logdev.__send__ :puts, *(args.join("\n") + "\n")
          self.__send__ "#{m}_without_capture", *args
        end
      end
    end
  end
end

Logger.__send__ :include, CapturedLogger if ENV['CI']

logger = Logger.new($stderr)
logger.progname = 'elasticsearch'
logger.formatter = proc do |severity, datetime, progname, msg|
  color = case severity
    when /INFO/ then :green
    when /ERROR|WARN|FATAL/ then :red
    when /DEBUG/ then :cyan
    else :white
  end
  "#{severity[0]} ".ansi(color, :faint) + msg.ansi(:white, :faint) + "\n"
end

tracer = Logger.new($stdout)
tracer.progname = 'elasticsearch.tracer'
tracer.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }

# Set up the client for the test
#
# To set up your own client, just set the `$client` variable in a file, and then require it:
#
#     ruby -I lib:test -r ./tmp/my_special_client.rb test/integration/yaml_test_runner.rb
#
url = ENV.fetch('TEST_CLUSTER_URL', "http://localhost:#{ENV['TEST_CLUSTER_PORT'] || 9250}")
$client ||= Elasticsearch::Client.new url: url
$helper_client ||= Elasticsearch::Client.new url: url

$client.transport.logger = logger unless ENV['QUIET'] || ENV['CI']
# $client.transport.tracer = tracer if ENV['CI']

# Store Elasticsearch version
#
es_version_info = $client.info['version']
$es_version = es_version_info['number']

puts '-'*80,
     "Elasticsearch #{$es_version.ansi(:bold)} [#{es_version_info['build_hash'].to_s[0...7]}]".center(80),
     '-'*80

require 'test_helper'
require 'test/unit'
require 'shoulda/context'

# Monkeypatch shoulda to remove "should" from test name
#
module Shoulda
  module Context
    class Context
      def create_test_from_should_hash(should)
        test_name = ["test:", full_name, "|", "#{should[:name]}"].flatten.join(' ').to_sym

        if test_methods[test_unit_class][test_name.to_s] then
          raise DuplicateTestError, "'#{test_name}' is defined more than once."
        end

        test_methods[test_unit_class][test_name.to_s] = true

        context = self
        test_unit_class.send(:define_method, test_name) do
          @shoulda_context = context
          begin
            context.run_parent_setup_blocks(self)
            should[:before].bind(self).call if should[:before]
            context.run_current_setup_blocks(self)
            should[:block].bind(self).call
          ensure
            context.run_all_teardown_blocks(self)
          end
        end
      end
    end
  end
end

module Elasticsearch
  module YamlTestSuite
    $last_response = ''
    $results = {}
    $stash   = {}

    module Utils
      def titleize(word)
        word.to_s.gsub(/[^\w]+/, ' ').gsub(/\b('?[a-z])/) { $1.capitalize }.tr('_', ' ')
      end

      def symbolize_keys(object)
        if object.is_a? Hash
          object.reduce({}) { |memo,(k,v)| memo[k.to_sym] = symbolize_keys(v); memo }
        else
          object
        end
      end

      extend self
    end

    module Runner
      def perform_api_call(test, api, arguments=nil)
        namespace = api.split('.')

        replacer = lambda do |value|
          case value
            when Array
              value.map { |v| replacer.call(v) }
            when Hash
              Hash[ value.map { |v| replacer.call(v) } ]
            else
              fetch_or_return value
          end
        end

        timefixer = lambda do |value|
          if value.is_a?(Time)
            value.iso8601
          else
            value
          end
        end

        arguments = Hash[
          arguments.map do |key, value|
            replacement = replacer.call(value)
            replacement = timefixer.call(replacement)
            [key, replacement]
          end
        ]

        $stderr.puts "ARGUMENTS: #{arguments.inspect}" if ENV['DEBUG']

        $last_response = namespace.reduce($client) do |memo, current|
          unless current == namespace.last
            memo = memo.send(current)
          else
            arguments ? memo = memo.send(current, arguments) : memo = memo.send(current)
          end
          memo
        end

        $results[test.hash] = $last_response
      end

      def evaluate(test, property, response=nil)
        response ||= $results[test.hash]
        property.gsub(/\\\./, '_____').split('.').reduce(response) do |memo, attr|
          if memo
            if attr
              attr = attr.gsub(/_____/, '.')
              attr = $stash[attr] if attr.start_with? '$'
            end
            memo = memo.is_a?(Hash) ? memo[attr] : memo[attr.to_i]
          end
          memo
        end
      end

      def in_context(name, &block)
        klass = Class.new(YamlTestCase)
        Object::const_set "%sTest" % name.split(/\s/).map { |d| d.capitalize }.join('').gsub(/[^\w]+/, ''), klass
        klass.context name, &block
      end

      def fetch_or_return(var)
        if var.is_a?(String) && var =~ /^\$(.+)/
          $stash[var]
        else
          var
        end
      end

      def set(var, val)
        $stash["$#{var}"] = val
      end

      def skip?(actions)
        skip = actions.select { |a| a['skip'] }.first
        $stderr.puts "SKIP: #{skip.inspect}" if ENV['DEBUG']

        def skip_version(skip)
          if skip && skip['skip']['version']

            return skip['skip']['reason'] ? skip['skip']['reason'] : true if skip['skip']['version'] == 'all'

            min, max = skip['skip']['version'].split('-').map(&:strip)

            min_normalized = sprintf "%03d-%03d-%03d",
                             *min.split('.')
                                 .map(&:to_i)
                                 .fill(0, min.split('.').length, 3-min.split('.').length)

            max_normalized = sprintf "%03d-%03d-%03d",
                             *max.split('.')
                                 .map(&:to_i)
                                 .map(&:to_i)
                                 .fill(0, max.split('.').length, 3-max.split('.').length)

            es_normalized  = sprintf "%03d-%03d-%03d", *$es_version.split('.').map(&:to_i)

            if ( min.empty? || min_normalized <= es_normalized ) && ( max.empty? || max_normalized >= es_normalized )
              return skip['skip']['reason'] ? skip['skip']['reason'] : true
            end

            return false
          end
        end

        def skip_features(skip)
          if skip && skip['skip']['features']
            skip_features = skip['skip']['features'].respond_to?(:split) ? skip['skip']['features'].split(',') : skip['skip']['features']
            if ( skip_features & SKIP_FEATURES.split(',') ).size > 0
              return skip['skip']['features']
            end
          end
        end

        return skip_version(skip) || skip_features(skip)
      end

      extend self
    end

    class YamlTestCase < ::Test::Unit::TestCase; end
  end
end

include Elasticsearch::YamlTestSuite

rest_api_test_source = $client.info['version']['number'] < '2' ? '../../../../tmp/elasticsearch/rest-api-spec/test' : '../../../../tmp/elasticsearch/rest-api-spec/src/main/resources/rest-api-spec/test'
PATH    = Pathname(ENV.fetch('TEST_REST_API_SPEC', File.expand_path(rest_api_test_source, __FILE__)))

suites  = Dir.glob(PATH.join('*')).map { |d| Pathname(d) }
suites  = suites.select { |s| s.to_s =~ Regexp.new(ENV['FILTER']) } if ENV['FILTER']

suites.each do |suite|
  name = Elasticsearch::YamlTestSuite::Utils.titleize(suite.basename)

  Elasticsearch::YamlTestSuite::Runner.in_context name do

    # --- Register context setup -------------------------------------------
    #
    setup do
      $helper_client.indices.delete index: '_all', ignore: 404
      $helper_client.indices.delete_template name: '*', ignore: 404
      $helper_client.snapshot.delete repository: 'test_repo_create_1',  snapshot: 'test_snapshot', ignore: 404
      $helper_client.snapshot.delete repository: 'test_repo_restore_1', snapshot: 'test_snapshot', ignore: 404
      $helper_client.snapshot.delete repository: 'test_cat_snapshots_1', snapshot: 'snap1', ignore: 404
      $helper_client.snapshot.delete repository: 'test_cat_snapshots_1', snapshot: 'snap2', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_repo_create_1', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_repo_restore_1', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_repo_get_1', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_repo_get_2', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_repo_status_1', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_cat_repo_1', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_cat_repo_2', ignore: 404
      $helper_client.snapshot.delete_repository repository: 'test_cat_snapshots_1', ignore: 404
      # FIXME: This shouldn't be needed -------------
      %w[
        test_cat_repo_1_loc
        test_cat_repo_2_loc
        test_cat_snapshots_1_loc
        test_repo_get_1_loc
        test_repo_status_1_loc
      ].each do |d|
        FileUtils.rm_rf("/tmp/#{d}")
      end
      # ---------------------------------------------
      $results = {}
      $stash   = {}
    end

    # --- Register context teardown ----------------------------------------
    #
    teardown do
      $helper_client.indices.delete index: '_all', ignore: 404
    end

    files = Dir[suite.join('*.{yml,yaml}')]
    files.each do |file|
      begin
        tests = YAML.load_documents File.new(file)
      rescue Exception => e
        $stderr.puts "ERROR [#{e.class}] while loading [#{file}] file".ansi(:red)
        # raise e
        next
      end

      # Extract setup actions
      setup_actions = tests.select { |t| t['setup'] }.first['setup'] rescue []

      # Skip all the tests when `skip` is part of the `setup` part
      if features = Runner.skip?(setup_actions)
        $stdout.puts "#{'SKIP'.ansi(:yellow)} [#{name}] #{file.gsub(PATH.to_s, '').ansi(:bold)} (Feature not implemented: #{features})"
        next
      end

      # Remove setup actions from tests
      tests = tests.reject { |t| t['setup'] }

      # Add setup actions to each individual test
      tests.each { |t| t[t.keys.first] << { 'setup' => setup_actions } }

      tests.each do |test|
        context '' do
          test_name = test.keys.first.to_s + (ENV['QUIET'] ? '' : " | #{file.gsub(PATH.to_s, '').ansi(:bold)}")
          actions   = test.values.first

          if reason = Runner.skip?(actions)
            $stdout.puts "#{'SKIP'.ansi(:yellow)} [#{name}] #{test_name} (Reason: #{reason})"
            next
          end

          # --- Register test setup -------------------------------------------
          setup do
            setup_actions = actions.select { |a| a['setup'] }
            setup_actions.first['setup'].each do |action|
              if action['do']
                api, arguments = action['do'].to_a.first
                arguments      = Utils.symbolize_keys(arguments)
                Runner.perform_api_call((test.to_s + '___setup'), api, arguments)
              end
              if action['set']
                stash = action['set']
                property, variable = stash.to_a.first
                result  = Runner.evaluate(test, property, $last_response)
                $stderr.puts "STASH: '$#{variable}' => #{result.inspect}" if ENV['DEBUG']
                Runner.set variable, result
              end
            end unless setup_actions.empty?
          end

          teardown do
            teardown_actions = actions.select { |a| a['teardown'] }
            teardown_actions.first['teardown'].each do |action|
              if action['do']
                api, arguments = action['do'].to_a.first
                arguments      = Utils.symbolize_keys(arguments)
                Runner.perform_api_call((test.to_s + '___teardown'), api, arguments)
              end
              if action['set']
                stash = action['set']
                property, variable = stash.to_a.first
                result  = Runner.evaluate(test, property, $last_response)
                $stderr.puts "STASH: '$#{variable}' => #{result.inspect}" if ENV['DEBUG']
                Runner.set variable, result
              end
            end unless teardown_actions.empty?
          end

          # --- Register test method ------------------------------------------
          should test_name do
            if ENV['CI']
              ref = ENV['TEST_BUILD_REF'].to_s.gsub(/origin\//, '') || 'master'
              $stderr.puts "https://github.com/elasticsearch/elasticsearch/blob/#{ref}/rest-api-spec/test/" \
                          + file.gsub(PATH.to_s, ''), ""
              $stderr.puts YAML.dump(test) if ENV['DEBUG']
            end
            actions.each do |action|
              $stderr.puts "ACTION: #{action.inspect}" if ENV['DEBUG']

              # This check verifies that the YAML has correct indentation.
              # See https://github.com/elastic/elasticsearch/issues/21980
              raise "INVALID YAML: #{action.inspect}" if action.keys.size != 1

              case

                # --- Perform action ------------------------------------------
                #
                when action['do']
                  catch_exception = action['do'].delete('catch') if action['do']
                  api, arguments = action['do'].to_a.first
                  arguments      = Utils.symbolize_keys(arguments)

                  begin
                    $results[test.hash] = Runner.perform_api_call(test, api, arguments)
                  rescue Exception => e
                    begin
                      $results[test.hash] = MultiJson.load(e.message.match(/{.+}/, 1).to_s)
                    rescue MultiJson::ParseError
                      $stderr.puts "RESPONSE: Cannot parse JSON from error message: '#{e.message}'" if ENV['DEBUG']
                    end

                    if catch_exception
                      $stderr.puts "CATCH: '#{catch_exception}': #{e.inspect}" if ENV['DEBUG']

                      if 'param' == catch_exception
                        assert_equal 'ArgumentError', e.class.to_s
                      else
                        if e.class.to_s =~ /Elasticsearch/
                          case catch_exception
                            when 'missing'
                              assert_match /\[404\]/, e.message
                            when 'conflict'
                              assert_match /\[409\]/, e.message
                            when 'request'
                              assert_match /\[4\d\d\]|\[5\d\d\]/, e.message
                            when /\/.+\//
                              assert_match Regexp.new(catch_exception.tr('/', '')), e.message
                          end
                        else
                          raise e
                        end
                      end

                    else
                      raise e
                    end
                  end

                # --- Evaluate predicates -------------------------------------
                #
                when property = action['is_true']
                  result = Runner.evaluate(test, property)
                  $stderr.puts "CHECK: Expected '#{property}' to be true, is: #{result.inspect}" if ENV['DEBUG']
                  assert(result, "Property '#{property}' should be true, is: #{result.inspect}")

                when property = action['is_false']
                  result = Runner.evaluate(test, property)
                  $stderr.puts "CHECK: Expected '#{property}' to be nil, false, 0 or empty string, is: #{result.inspect}" if ENV['DEBUG']
                  assert_block "Property '#{property}' should be nil, false, 0 or empty string, but is: #{result.inspect}" do
                    result.nil? || result == false || result == 0 || result == ''
                  end

                when a = action['match']
                  property, value = a.to_a.first

                  if value.is_a?(String) && value =~ %r{\s*^/\s*.*\s*/$\s*}mx # Begins and ends with /
                    pattern = Regexp.new(value.strip[1..-2], Regexp::EXTENDED|Regexp::MULTILINE)
                  else
                    value  = Runner.fetch_or_return(value)
                  end

                  if property == '$body'
                    result = $results[test.hash]
                  else
                    result = Runner.evaluate(test, property)
                  end

                  if pattern
                    $stderr.puts "CHECK: Expected '#{property}' to match #{pattern}, is: #{result.inspect}" if ENV['DEBUG']
                    assert_match(pattern, result)
                  else
                    value = value.reduce({}) { |memo, (k,v)| memo[k] =  Runner.fetch_or_return(v); memo  } if value.is_a? Hash
                    $stderr.puts "CHECK: Expected '#{property}' to be '#{value}', is: #{result.inspect}" if ENV['DEBUG']

                    assert_equal(value, result)
                  end

                when a = action['length']
                  property, value = a.to_a.first

                  result = Runner.evaluate(test, property)
                  length = result.size
                  $stderr.puts "CHECK: Expected '#{property}' to be #{value}, is: #{length.inspect}" if ENV['DEBUG']
                  assert_equal(value, length)

                when a = action['lt'] || action['gt'] || action['lte'] || action['gte']
                  property, value = a.to_a.first
                  operator = case
                    when action['lt']
                      '<'
                    when action['gt']
                      '>'
                    when action['lte']
                      '<='
                    when action['gte']
                      '>='
                  end

                  result  = Runner.evaluate(test, property)
                  message = "Expected '#{property}' to be #{operator} #{value}, is: #{result.inspect}"

                  $stderr.puts "CHECK: #{message}" if ENV['DEBUG']
                  assert_operator result, operator.to_sym, value.to_i

                when stash = action['set']
                  property, variable = stash.to_a.first
                  result  = Runner.evaluate(test, property)
                  $stderr.puts "STASH: '$#{variable}' => #{result.inspect}" if ENV['DEBUG']
                  Runner.set variable, result
              end
            end
          end
        end
      end
    end

  end

end
