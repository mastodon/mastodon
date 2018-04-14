# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
# vim: set ft=ruby

## DEFINE VARIABLES
@minimum_coverage = ENV.fetch('COVERAGE_MINIMUM') {
  case (defined?(RUBY_ENGINE) && RUBY_ENGINE) || "ruby"
  when 'jruby', 'rbx'
    96.0
  else
    98.1
  end
}.to_f.round(2)
# rubocop:disable Style/DoubleNegation
ENV['FULL_BUILD'] ||= ENV['CI']
@running_ci       = !!(ENV['FULL_BUILD'] =~ /\Atrue\z/i)
@generate_report  = @running_ci || !!(ENV['COVERAGE'] =~ /\Atrue\z/i)
@output = STDOUT
# rubocop:enable Style/DoubleNegation

## CONFIGURE SIMPLECOV

SimpleCov.profiles.define 'app' do
  coverage_dir 'coverage'
  load_profile 'test_frameworks'

  add_group 'Libraries', 'lib'

  add_group 'Long files' do |src_file|
    src_file.lines.count > 100
  end
  class MaxLinesFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.lines.count < filter_argument
    end
  end
  add_group 'Short files', MaxLinesFilter.new(5)

  # Exclude these paths from analysis
  add_filter '/config/'
  add_filter '/db/'
  add_filter 'tasks'
  add_filter '/.bundle/'
end

## START TRACKING COVERAGE (before activating SimpleCov)
require 'coverage'
Coverage.start

## ADD SOME CUSTOM REPORTING AT EXIT
SimpleCov.at_exit do
  next if $! and not ($!.kind_of? SystemExit and $!.success?)

  header = "#{'*' * 20} SimpleCov Results #{'*' * 20}"
  results = SimpleCov.result.format!.join("\n")
  exit_message = <<-EOF

#{header}
{{RESULTS}}
{{FAILURE_MESSAGE}}

#{'*' * header.size}
  EOF
  percent = Float(SimpleCov.result.covered_percent)
  if percent < @minimum_coverage
    failure_message = <<-EOF
Spec coverage was not high enough: #{percent.round(2)}% is < #{@minimum_coverage}%
    EOF
    exit_message.sub!('{{RESULTS}}', results).sub!('{{FAILURE_MESSAGE}}', failure_message)
    @output.puts exit_message
    abort(failure_message) if @generate_report
  elsif @running_ci
    exit_message.sub!('{{RESULTS}}', results).sub!('{{FAILURE_MESSAGE}}', <<-EOF)
Nice job! Spec coverage (#{percent.round(2)}%) is still at or above #{@minimum_coverage}%
    EOF
    @output.puts exit_message
  end
end

## CAPTURE CONFIG IN CLOSURE 'AppCoverage.start'
## to defer running until test/test_helper.rb is loaded.
# rubocop:disable Style/MultilineBlockChain
AppCoverage = Class.new do
  def initialize(&block)
    @block = block
  end

  def start
    @block.call
  end
end.new do
  SimpleCov.start 'app'
  if @generate_report
    if @running_ci
      require 'codeclimate-test-reporter'
      @output.puts '[COVERAGE] Running with SimpleCov Simple Formatter and CodeClimate Test Reporter'
      formatters = [
        SimpleCov::Formatter::SimpleFormatter,
        CodeClimate::TestReporter::Formatter
      ]
    else
      @output.puts '[COVERAGE] Running with SimpleCov HTML Formatter'
      formatters = [SimpleCov::Formatter::HTMLFormatter]
    end
  else
    formatters = []
  end
  SimpleCov.formatters = formatters
end
# rubocop:enable Style/MultilineBlockChain
