require "tempfile"
require "stringio"
require "minitest/autorun"

class Minitest::Test
  def clean s
    s.gsub(/^ {6}/, "")
  end
end

class FakeNamedTest < Minitest::Test
  @@count = 0

  def self.name
    @fake_name ||= begin
                     @@count += 1
                     "FakeNamedTest%02d" % @@count
                   end
  end
end

class MetaMetaMetaTestCase < Minitest::Test
  attr_accessor :reporter, :output, :tu

  def run_tu_with_fresh_reporter flags = %w[--seed 42]
    options = Minitest.process_args flags

    @output = StringIO.new("".encode('UTF-8'))

    self.reporter = Minitest::CompositeReporter.new
    reporter << Minitest::SummaryReporter.new(@output, options)
    reporter << Minitest::ProgressReporter.new(@output, options)

    reporter.start

    yield(reporter) if block_given?

    @tus ||= [@tu]
    @tus.each do |tu|
      Minitest::Runnable.runnables.delete tu

      tu.run reporter, options
    end

    reporter.report
  end

  def first_reporter
    reporter.reporters.first
  end

  def assert_report expected, flags = %w[--seed 42], &block
    header = clean <<-EOM
      Run options: #{flags.map { |s| s =~ /\|/ ? s.inspect : s }.join " "}

      # Running:

    EOM

    run_tu_with_fresh_reporter flags, &block

    output = normalize_output @output.string.dup

    assert_equal header + expected, output
  end

  def normalize_output output
    output.sub!(/Finished in .*/, "Finished in 0.00")
    output.sub!(/Loaded suite .*/, "Loaded suite blah")

    output.gsub!(/FakeNamedTest\d+/, "FakeNamedTestXX")
    output.gsub!(/ = \d+.\d\d s = /, " = 0.00 s = ")
    output.gsub!(/0x[A-Fa-f0-9]+/, "0xXXX")
    output.gsub!(/ +$/, "")

    if windows? then
      output.gsub!(/\[(?:[A-Za-z]:)?[^\]:]+:\d+\]/, "[FILE:LINE]")
      output.gsub!(/^(\s+)(?:[A-Za-z]:)?[^:]+:\d+:in/, '\1FILE:LINE:in')
    else
      output.gsub!(/\[[^\]:]+:\d+\]/, "[FILE:LINE]")
      output.gsub!(/^(\s+)[^:]+:\d+:in/, '\1FILE:LINE:in')
    end

    output
  end

  def restore_env
    old_value = ENV["MT_NO_SKIP_MSG"]
    ENV.delete "MT_NO_SKIP_MSG"

    yield
  ensure
    ENV["MT_NO_SKIP_MSG"] = old_value
  end

  def setup
    super
    srand 42
    Minitest::Test.reset
    @tu = nil
  end
end
