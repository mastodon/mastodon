require "minitest/autorun"
require "minitest/metametameta"

class Runnable
  def woot
    assert true
  end
end

class TestMinitestReporter < MetaMetaMetaTestCase

  attr_accessor :r, :io

  def new_composite_reporter
    reporter = Minitest::CompositeReporter.new
    reporter << Minitest::SummaryReporter.new(self.io)
    reporter << Minitest::ProgressReporter.new(self.io)

    def reporter.first
      reporters.first
    end

    def reporter.results
      first.results
    end

    def reporter.count
      first.count
    end

    def reporter.assertions
      first.assertions
    end

    reporter
  end

  def setup
    self.io = StringIO.new("")
    self.r  = new_composite_reporter
  end

  def error_test
    unless defined? @et then
      @et = Minitest::Test.new(:woot)
      @et.failures << Minitest::UnexpectedError.new(begin
                                                      raise "no"
                                                    rescue => e
                                                      e
                                                    end)
      @et = Minitest::Result.from @et
    end
    @et
  end

  def fail_test
    unless defined? @ft then
      @ft = Minitest::Test.new(:woot)
      @ft.failures <<   begin
                          raise Minitest::Assertion, "boo"
                        rescue Minitest::Assertion => e
                          e
                        end
      @ft = Minitest::Result.from @ft
    end
    @ft
  end

  def passing_test
    @pt ||= Minitest::Result.from Minitest::Test.new(:woot)
  end

  def skip_test
    unless defined? @st then
      @st = Minitest::Test.new(:woot)
      @st.failures << begin
                        raise Minitest::Skip
                      rescue Minitest::Assertion => e
                        e
                      end
      @st = Minitest::Result.from @st
    end
    @st
  end

  def test_to_s
    r.record passing_test
    r.record fail_test
    assert_match "woot", r.first.to_s
  end

  def test_passed_eh_empty
    assert_predicate r, :passed?
  end

  def test_passed_eh_failure
    r.results << fail_test

    refute_predicate r, :passed?
  end

  SKIP_MSG = "\n\nYou have skipped tests. Run with --verbose for details."

  def test_passed_eh_error
    r.start

    r.results << error_test

    refute_predicate r, :passed?

    r.report

    refute_match SKIP_MSG, io.string
  end

  def test_passed_eh_skipped
    r.start
    r.results << skip_test
    assert r.passed?

    restore_env do
      r.report
    end

    assert_match SKIP_MSG, io.string
  end

  def test_passed_eh_skipped_verbose
    r.first.options[:verbose] = true

    r.start
    r.results << skip_test
    assert r.passed?
    r.report

    refute_match SKIP_MSG, io.string
  end

  def test_start
    r.start

    exp = "Run options: \n\n# Running:\n\n"

    assert_equal exp, io.string
  end

  def test_record_pass
    r.record passing_test

    assert_equal ".", io.string
    assert_empty r.results
    assert_equal 1, r.count
    assert_equal 0, r.assertions
  end

  def test_record_fail
    fail_test = self.fail_test
    r.record fail_test

    assert_equal "F", io.string
    assert_equal [fail_test], r.results
    assert_equal 1, r.count
    assert_equal 0, r.assertions
  end

  def test_record_error
    error_test = self.error_test
    r.record error_test

    assert_equal "E", io.string
    assert_equal [error_test], r.results
    assert_equal 1, r.count
    assert_equal 0, r.assertions
  end

  def test_record_skip
    skip_test = self.skip_test
    r.record skip_test

    assert_equal "S", io.string
    assert_equal [skip_test], r.results
    assert_equal 1, r.count
    assert_equal 0, r.assertions
  end

  def test_report_empty
    r.start
    r.report

    exp = clean <<-EOM
      Run options:

      # Running:



      Finished in 0.00

      0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_equal exp, normalize_output(io.string)
  end

  def test_report_passing
    r.start
    r.record passing_test
    r.report

    exp = clean <<-EOM
      Run options:

      # Running:

      .

      Finished in 0.00

      1 runs, 0 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_equal exp, normalize_output(io.string)
  end

  def test_report_failure
    r.start
    r.record fail_test
    r.report

    exp = clean <<-EOM
      Run options:

      # Running:

      F

      Finished in 0.00

        1) Failure:
      Minitest::Test#woot [FILE:LINE]:
      boo

      1 runs, 0 assertions, 1 failures, 0 errors, 0 skips
    EOM

    assert_equal exp, normalize_output(io.string)
  end

  def test_report_error
    r.start
    r.record error_test
    r.report

    exp = clean <<-EOM
      Run options:

      # Running:

      E

      Finished in 0.00

        1) Error:
      Minitest::Test#woot:
      RuntimeError: no
          FILE:LINE:in `error_test'
          FILE:LINE:in `test_report_error'

      1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
    EOM

    assert_equal exp, normalize_output(io.string)
  end

  def test_report_skipped
    r.start
    r.record skip_test

    restore_env do
      r.report
    end

    exp = clean <<-EOM
      Run options:

      # Running:

      S

      Finished in 0.00

      1 runs, 0 assertions, 0 failures, 0 errors, 1 skips

      You have skipped tests. Run with --verbose for details.
    EOM

    assert_equal exp, normalize_output(io.string)
  end
end
