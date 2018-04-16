# encoding: UTF-8

require "pathname"
require "minitest/metametameta"

if defined? Encoding then
  e = Encoding.default_external
  if e != Encoding::UTF_8 then
    warn ""
    warn ""
    warn "NOTE: External encoding #{e} is not UTF-8. Tests WILL fail."
    warn "      Run tests with `RUBYOPT=-Eutf-8 rake` to avoid errors."
    warn ""
    warn ""
  end
end

module MyModule; end
class AnError < StandardError; include MyModule; end
class ImmutableString < String; def inspect; super.freeze; end; end
SomeError = Class.new Exception

class Minitest::Runnable
  def whatever # faked for testing
    assert true
  end
end

class TestMinitestUnit < MetaMetaMetaTestCase
  parallelize_me!

  pwd = Pathname.new File.expand_path Dir.pwd
  basedir = Pathname.new(File.expand_path "lib/minitest") + "mini"
  basedir = basedir.relative_path_from(pwd).to_s
  MINITEST_BASE_DIR = basedir[/\A\./] ? basedir : "./#{basedir}"
  BT_MIDDLE = ["#{MINITEST_BASE_DIR}/test.rb:161:in `each'",
               "#{MINITEST_BASE_DIR}/test.rb:158:in `each'",
               "#{MINITEST_BASE_DIR}/test.rb:139:in `run'",
               "#{MINITEST_BASE_DIR}/test.rb:106:in `run'"]

  def test_filter_backtrace
    # this is a semi-lame mix of relative paths.
    # I cheated by making the autotest parts not have ./
    bt = (["lib/autotest.rb:571:in `add_exception'",
           "test/test_autotest.rb:62:in `test_add_exception'",
           "#{MINITEST_BASE_DIR}/test.rb:165:in `__send__'"] +
          BT_MIDDLE +
          ["#{MINITEST_BASE_DIR}/test.rb:29",
           "test/test_autotest.rb:422"])
    bt = util_expand_bt bt

    ex = ["lib/autotest.rb:571:in `add_exception'",
          "test/test_autotest.rb:62:in `test_add_exception'"]
    ex = util_expand_bt ex

    fu = Minitest.filter_backtrace(bt)

    assert_equal ex, fu
  end

  def test_filter_backtrace_all_unit
    bt = (["#{MINITEST_BASE_DIR}/test.rb:165:in `__send__'"] +
          BT_MIDDLE +
          ["#{MINITEST_BASE_DIR}/test.rb:29"])
    ex = bt.clone
    fu = Minitest.filter_backtrace(bt)
    assert_equal ex, fu
  end

  def test_filter_backtrace_unit_starts
    bt = (["#{MINITEST_BASE_DIR}/test.rb:165:in `__send__'"] +
          BT_MIDDLE +
          ["#{MINITEST_BASE_DIR}/mini/test.rb:29",
           "-e:1"])

    bt = util_expand_bt bt

    ex = ["-e:1"]
    fu = Minitest.filter_backtrace bt
    assert_equal ex, fu
  end

  # def test_default_runner_is_minitest_unit
  #   assert_instance_of Minitest::Unit, Minitest::Unit.runner
  # end

  def test_infectious_binary_encoding
    @tu = Class.new FakeNamedTest do
      def test_this_is_not_ascii_assertion
        assert_equal "ЁЁЁ", "ёёё"
      end

      def test_this_is_non_ascii_failure_message
        fail 'ЁЁЁ'.force_encoding('ASCII-8BIT')
      end
    end

    expected = clean <<-EOM
      EF

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_this_is_non_ascii_failure_message:
      RuntimeError: ЁЁЁ
          FILE:LINE:in `test_this_is_non_ascii_failure_message'

        2) Failure:
      FakeNamedTestXX#test_this_is_not_ascii_assertion [FILE:LINE]:
      Expected: \"ЁЁЁ\"
        Actual: \"ёёё\"

      2 runs, 1 assertions, 1 failures, 1 errors, 0 skips
    EOM

    assert_report expected
  end

  def test_passed_eh_teardown_good
    test_class = Class.new FakeNamedTest do
      def teardown; assert true; end
      def test_omg; assert true; end
    end

    test = test_class.new :test_omg
    test.run

    refute_predicate test, :error?
    assert_predicate test, :passed?
    refute_predicate test, :skipped?
  end

  def test_passed_eh_teardown_skipped
    test_class = Class.new FakeNamedTest do
      def teardown; assert true; end
      def test_omg; skip "bork"; end
    end

    test = test_class.new :test_omg
    test.run

    refute_predicate test, :error?
    refute_predicate test, :passed?
    assert_predicate test, :skipped?
  end

  def test_passed_eh_teardown_flunked
    test_class = Class.new FakeNamedTest do
      def teardown; flunk;       end
      def test_omg; assert true; end
    end

    test = test_class.new :test_omg
    test.run

    refute_predicate test, :error?
    refute_predicate test, :passed?
    refute_predicate test, :skipped?
  end

  def util_expand_bt bt
    if RUBY_VERSION >= "1.9.0" then
      bt.map { |f| (f =~ /^\./) ? File.expand_path(f) : f }
    else
      bt
    end
  end
end

class TestMinitestUnitInherited < MetaMetaMetaTestCase
  def with_overridden_include
    Class.class_eval do
      def inherited_with_hacks _klass
        throw :inherited_hook
      end

      alias inherited_without_hacks inherited
      alias inherited               inherited_with_hacks
      alias IGNORE_ME!              inherited # 1.8 bug. god I love venture bros
    end

    yield
  ensure
    Class.class_eval do
      alias inherited inherited_without_hacks

      undef_method :inherited_with_hacks
      undef_method :inherited_without_hacks
    end

    refute_respond_to Class, :inherited_with_hacks
    refute_respond_to Class, :inherited_without_hacks
  end

  def test_inherited_hook_plays_nice_with_others
    with_overridden_include do
      assert_throws :inherited_hook do
        Class.new FakeNamedTest
      end
    end
  end
end

class TestMinitestRunner < MetaMetaMetaTestCase
  # do not parallelize this suite... it just can't handle it.

  def test_class_runnables
    @assertion_count = 0

    tc = Class.new(Minitest::Test)

    assert_equal 1, Minitest::Test.runnables.size
    assert_equal [tc], Minitest::Test.runnables
  end

  def test_run_test
    @tu =
    Class.new FakeNamedTest do
      attr_reader :foo

      def run
        @foo = "hi mom!"
        r = super
        @foo = "okay"

        r
      end

      def test_something
        assert_equal "hi mom!", foo
      end
    end

    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report expected
  end

  def test_run_error
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end

      def test_error
        raise "unhandled exception"
      end
    end

    expected = clean <<-EOM
      E.

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_error:
      RuntimeError: unhandled exception
          FILE:LINE:in \`test_error\'

      2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
    EOM

    assert_report expected
  end

  def test_run_error_teardown
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end

      def teardown
        raise "unhandled exception"
      end
    end

    expected = clean <<-EOM
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_something:
      RuntimeError: unhandled exception
          FILE:LINE:in \`teardown\'

      1 runs, 1 assertions, 0 failures, 1 errors, 0 skips
    EOM

    assert_report expected
  end

  def test_run_failing
    setup_basic_tu

    expected = clean <<-EOM
      F.

      Finished in 0.00

        1) Failure:
      FakeNamedTestXX#test_failure [FILE:LINE]:
      Expected false to be truthy.

      2 runs, 2 assertions, 1 failures, 0 errors, 0 skips
    EOM

    assert_report expected
  end

  def setup_basic_tu
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end

      def test_failure
        assert false
      end
    end
  end

  def test_run_failing_filtered
    setup_basic_tu

    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report expected, %w[--name /some|thing/ --seed 42]
  end

  def assert_filtering filter, name, expected, a = false
    args = %W[--#{filter} #{name} --seed 42]

    alpha = Class.new FakeNamedTest do
      define_method :test_something do
        assert a
      end
    end
    Object.const_set(:Alpha, alpha)

    beta = Class.new FakeNamedTest do
      define_method :test_something do
        assert true
      end
    end
    Object.const_set(:Beta, beta)

    @tus = [alpha, beta]

    assert_report expected, args
  ensure
    Object.send :remove_const, :Alpha
    Object.send :remove_const, :Beta
  end

  def test_run_filtered_including_suite_name
    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "name", "/Beta#test_something/", expected
  end

  def test_run_filtered_including_suite_name_string
    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "name", "Beta#test_something", expected
  end

  def test_run_filtered_string_method_only
    expected = clean <<-EOM
      ..

      Finished in 0.00

      2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "name", "test_something", expected, :pass
  end

  def test_run_failing_excluded
    setup_basic_tu

    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report expected, %w[--exclude /failure/ --seed 42]
  end

  def test_run_filtered_excluding_suite_name
    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "exclude", "/Alpha#test_something/", expected
  end

  def test_run_filtered_excluding_suite_name_string
    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "exclude", "Alpha#test_something", expected
  end

  def test_run_filtered_excluding_string_method_only
    expected = clean <<-EOM


      Finished in 0.00

      0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_filtering "exclude", "test_something", expected, :pass
  end

  def test_run_passing
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end
    end

    expected = clean <<-EOM
      .

      Finished in 0.00

      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report expected
  end

  def test_run_skip
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end

      def test_skip
        skip "not yet"
      end
    end

    expected = clean <<-EOM
      S.

      Finished in 0.00

      2 runs, 1 assertions, 0 failures, 0 errors, 1 skips

      You have skipped tests. Run with --verbose for details.
    EOM

    restore_env do
      assert_report expected
    end
  end

  def test_run_skip_verbose
    @tu =
    Class.new FakeNamedTest do
      def test_something
        assert true
      end

      def test_skip
        skip "not yet"
      end
    end

    expected = clean <<-EOM
      FakeNamedTestXX#test_skip = 0.00 s = S
      FakeNamedTestXX#test_something = 0.00 s = .

      Finished in 0.00

        1) Skipped:
      FakeNamedTestXX#test_skip [FILE:LINE]:
      not yet

      2 runs, 1 assertions, 0 failures, 0 errors, 1 skips
    EOM

    assert_report expected, %w[--seed 42 --verbose]
  end

  def test_run_with_other_runner
    @tu =
    Class.new FakeNamedTest do
      def self.run reporter, options = {}
        @reporter = reporter
        before_my_suite
        super
      end

      def self.name; "wacky!" end

      def self.before_my_suite
        @reporter.io.puts "Running #{self.name} tests"
        @@foo = 1
      end

      def test_something
        assert_equal 1, @@foo
      end

      def test_something_else
        assert_equal 1, @@foo
      end
    end

    expected = clean <<-EOM
      Running wacky! tests
      ..

      Finished in 0.00

      2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report expected
  end

  require "monitor"

  class Latch
    def initialize count = 1
      @count = count
      @lock  = Monitor.new
      @cv    = @lock.new_cond
    end

    def release
      @lock.synchronize do
        @count -= 1 if @count > 0
        @cv.broadcast if @count == 0
      end
    end

    def await
      @lock.synchronize { @cv.wait_while { @count > 0 } }
    end
  end

  def test_run_parallel
    skip "I don't have ParallelEach debugged yet" if maglev?

    test_count = 2
    test_latch = Latch.new test_count
    wait_latch = Latch.new test_count
    main_latch = Latch.new

    thread = Thread.new {
      Thread.current.abort_on_exception = true

      # This latch waits until both test latches have been released.  Both
      # latches can't be released unless done in separate threads because
      # `main_latch` keeps the test method from finishing.
      test_latch.await
      main_latch.release
    }

    @tu =
    Class.new FakeNamedTest do
      parallelize_me!

      test_count.times do |i|
        define_method :"test_wait_on_main_thread_#{i}" do
          test_latch.release

          # This latch blocks until the "main thread" releases it. The main
          # thread can't release this latch until both test latches have
          # been released.  This forces the latches to be released in separate
          # threads.
          main_latch.await
          assert true
        end
      end
    end

    expected = clean <<-EOM
      ..

      Finished in 0.00

      2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report(expected) do |reporter|
      reporter.extend(Module.new {
        define_method("record") do |result|
          super(result)
          wait_latch.release
        end

        define_method("report") do
          wait_latch.await
          super()
        end
      })
    end
    assert thread.join
  end
end

class TestMinitestUnitOrder < MetaMetaMetaTestCase
  # do not parallelize this suite... it just can't handle it.

  def test_before_setup
    call_order = []
    @tu =
    Class.new FakeNamedTest do
      define_method :setup do
        super()
        call_order << :setup
      end

      define_method :before_setup do
        call_order << :before_setup
      end

      def test_omg; assert true; end
    end

    run_tu_with_fresh_reporter

    expected = [:before_setup, :setup]
    assert_equal expected, call_order
  end

  def test_after_teardown
    call_order = []
    @tu =
    Class.new FakeNamedTest do
      define_method :teardown do
        super()
        call_order << :teardown
      end

      define_method :after_teardown do
        call_order << :after_teardown
      end

      def test_omg; assert true; end
    end

    run_tu_with_fresh_reporter

    expected = [:teardown, :after_teardown]
    assert_equal expected, call_order
  end

  def test_all_teardowns_are_guaranteed_to_run
    call_order = []
    @tu =
    Class.new FakeNamedTest do
      define_method :after_teardown do
        super()
        call_order << :after_teardown
        raise
      end

      define_method :teardown do
        super()
        call_order << :teardown
        raise
      end

      define_method :before_teardown do
        super()
        call_order << :before_teardown
        raise
      end

      def test_omg; assert true; end
    end

    run_tu_with_fresh_reporter

    expected = [:before_teardown, :teardown, :after_teardown]
    assert_equal expected, call_order
  end

  def test_setup_and_teardown_survive_inheritance
    call_order = []

    @tu = Class.new FakeNamedTest do
      define_method :setup do
        call_order << :setup_method
      end

      define_method :teardown do
        call_order << :teardown_method
      end

      define_method :test_something do
        call_order << :test
      end
    end

    run_tu_with_fresh_reporter

    @tu = Class.new @tu
    run_tu_with_fresh_reporter

    # Once for the parent class, once for the child
    expected = [:setup_method, :test, :teardown_method] * 2

    assert_equal expected, call_order
  end
end

class TestMinitestRunnable < Minitest::Test
  def setup_marshal klass
    tc = klass.new "whatever"
    tc.assertions = 42
    tc.failures << "a failure"

    yield tc if block_given?

    def tc.setup
      @blah = "blah"
    end
    tc.setup

    @tc = Minitest::Result.from tc
  end

  def assert_marshal expected_ivars
    new_tc = Marshal.load Marshal.dump @tc

    ivars = new_tc.instance_variables.map(&:to_s).sort
    assert_equal expected_ivars, ivars
    assert_equal "whatever",     new_tc.name
    assert_equal 42,             new_tc.assertions
    assert_equal ["a failure"],  new_tc.failures

    yield new_tc if block_given?
  end

  def test_marshal
    setup_marshal Minitest::Runnable

    assert_marshal %w[@NAME @assertions @failures @klass @source_location @time]
  end

  def test_spec_marshal
    klass = describe("whatever") { it("passes") { assert true } }
    rm = klass.runnable_methods.first

    # Run the test
    @tc = klass.new(rm).run

    assert_kind_of Minitest::Result, @tc

    # Pass it over the wire
    over_the_wire = Marshal.load Marshal.dump @tc

    assert_equal @tc.time,       over_the_wire.time
    assert_equal @tc.name,       over_the_wire.name
    assert_equal @tc.assertions, over_the_wire.assertions
    assert_equal @tc.failures,   over_the_wire.failures
    assert_equal @tc.klass,      over_the_wire.klass
  end
end

class TestMinitestTest < TestMinitestRunnable
  def test_dup
    setup_marshal Minitest::Test do |tc|
      tc.time = 3.14
    end

    assert_marshal %w[@NAME @assertions @failures @klass @source_location @time] do |new_tc|
      assert_in_epsilon 3.14, new_tc.time
    end
  end
end

class TestMinitestUnitTestCase < Minitest::Test
  # do not call parallelize_me! - teardown accesses @tc._assertions
  # which is not threadsafe. Nearly every method in here is an
  # assertion test so it isn't worth splitting it out further.

  RUBY18 = !defined? Encoding

  def setup
    super

    Minitest::Test.reset

    @tc = Minitest::Test.new "fake tc"
    @zomg = "zomg ponies!"
    @assertion_count = 1
  end

  def teardown
    assert_equal(@assertion_count, @tc.assertions,
                 "expected #{@assertion_count} assertions to be fired during the test, not #{@tc.assertions}") if @tc.passed?
  end

  def non_verbose
    orig_verbose = $VERBOSE
    $VERBOSE = false

    yield
  ensure
    $VERBOSE = orig_verbose
  end

  def test_assert
    @assertion_count = 2

    @tc.assert_equal true, @tc.assert(true), "returns true on success"
  end

  def test_assert__triggered
    assert_triggered "Expected false to be truthy." do
      @tc.assert false
    end
  end

  def test_assert__triggered_message
    assert_triggered @zomg do
      @tc.assert false, @zomg
    end
  end

  def test_assert_empty
    @assertion_count = 2

    @tc.assert_empty []
  end

  def test_assert_empty_triggered
    @assertion_count = 2

    assert_triggered "Expected [1] to be empty." do
      @tc.assert_empty [1]
    end
  end

  def test_assert_equal
    @tc.assert_equal 1, 1
  end

  def test_assert_equal_different_collection_array_hex_invisible
    object1 = Object.new
    object2 = Object.new
    msg = "No visible difference in the Array#inspect output.
           You should look at the implementation of #== on Array or its members.
           [#<Object:0xXXXXXX>]".gsub(/^ +/, "")
    assert_triggered msg do
      @tc.assert_equal [object1], [object2]
    end
  end

  def test_assert_equal_different_collection_hash_hex_invisible
    h1, h2 = {}, {}
    h1[1] = Object.new
    h2[1] = Object.new
    msg = "No visible difference in the Hash#inspect output.
           You should look at the implementation of #== on Hash or its members.
           {1=>#<Object:0xXXXXXX>}".gsub(/^ +/, "")

    assert_triggered msg do
      @tc.assert_equal h1, h2
    end
  end

  def test_assert_equal_string_encodings
    msg = <<-EOM.gsub(/^ {10}/, "")
          --- expected
          +++ actual
          @@ -1 +1,2 @@
          +# encoding: ASCII-8BIT
           "bad-utf8-\\xF1.txt"
          EOM

    assert_triggered msg do
      x = "bad-utf8-\xF1.txt"
      y = x.dup.force_encoding "binary" # TODO: switch to .b when 1.9 dropped
      @tc.assert_equal x, y
    end
  end unless RUBY18

  def test_assert_equal_string_encodings_both_different
    msg = <<-EOM.gsub(/^ {10}/, "")
          --- expected
          +++ actual
          @@ -1,2 +1,2 @@
          -# encoding: US-ASCII
          +# encoding: ASCII-8BIT
           "bad-utf8-\\xF1.txt"
          EOM

    assert_triggered msg do
      x = "bad-utf8-\xF1.txt".force_encoding "ASCII"
      y = x.dup.force_encoding "binary" # TODO: switch to .b when 1.9 dropped
      @tc.assert_equal x, y
    end
  end unless RUBY18

  def test_assert_equal_different_diff_deactivated
    skip "https://github.com/MagLev/maglev/issues/209" if maglev?

    without_diff do
      assert_triggered util_msg("haha" * 10, "blah" * 10) do
        o1 = "haha" * 10
        o2 = "blah" * 10

        @tc.assert_equal o1, o2
      end
    end
  end

  def test_assert_equal_different_hex
    c = Class.new do
      def initialize s; @name = s; end
    end

    o1 = c.new "a"
    o2 = c.new "b"
    msg = "--- expected
           +++ actual
           @@ -1 +1 @@
           -#<#<Class:0xXXXXXX>:0xXXXXXX @name=\"a\">
           +#<#<Class:0xXXXXXX>:0xXXXXXX @name=\"b\">
           ".gsub(/^ +/, "")

    assert_triggered msg do
      @tc.assert_equal o1, o2
    end
  end

  def test_assert_equal_different_hex_invisible
    o1 = Object.new
    o2 = Object.new

    msg = "No visible difference in the Object#inspect output.
           You should look at the implementation of #== on Object or its members.
           #<Object:0xXXXXXX>".gsub(/^ +/, "")

    assert_triggered msg do
      @tc.assert_equal o1, o2
    end
  end

  def test_assert_equal_different_long
    msg = "--- expected
           +++ actual
           @@ -1 +1 @@
           -\"hahahahahahahahahahahahahahahahahahahaha\"
           +\"blahblahblahblahblahblahblahblahblahblah\"
           ".gsub(/^ +/, "")

    assert_triggered msg do
      o1 = "haha" * 10
      o2 = "blah" * 10

      @tc.assert_equal o1, o2
    end
  end

  def test_assert_equal_different_long_invisible
    msg = "No visible difference in the String#inspect output.
           You should look at the implementation of #== on String or its members.
           \"blahblahblahblahblahblahblahblahblahblah\"".gsub(/^ +/, "")

    assert_triggered msg do
      o1 = "blah" * 10
      o2 = "blah" * 10
      def o1.== _
        false
      end
      @tc.assert_equal o1, o2
    end
  end

  def test_assert_equal_different_long_msg
    msg = "message.
           --- expected
           +++ actual
           @@ -1 +1 @@
           -\"hahahahahahahahahahahahahahahahahahahaha\"
           +\"blahblahblahblahblahblahblahblahblahblah\"
           ".gsub(/^ +/, "")

    assert_triggered msg do
      o1 = "haha" * 10
      o2 = "blah" * 10
      @tc.assert_equal o1, o2, "message"
    end
  end

  def test_assert_equal_different_short
    assert_triggered util_msg(1, 2) do
      @tc.assert_equal 1, 2
    end
  end

  def test_assert_equal_different_short_msg
    assert_triggered util_msg(1, 2, "message") do
      @tc.assert_equal 1, 2, "message"
    end
  end

  def test_assert_equal_different_short_multiline
    msg = "--- expected\n+++ actual\n@@ -1,2 +1,2 @@\n \"a\n-b\"\n+c\"\n"
    assert_triggered msg do
      @tc.assert_equal "a\nb", "a\nc"
    end
  end

  def test_assert_equal_does_not_allow_lhs_nil
    if Minitest::VERSION =~ /^6/ then
      warn "Time to strip the MT5 test"

      @assertion_count += 1
      assert_triggered(/Use assert_nil if expecting nil/) do
        @tc.assert_equal nil, nil
      end
    else
      err_re = /Use assert_nil if expecting nil from .*test_minitest_test.rb/
      err_re = "" if $-w.nil?

      assert_output "", err_re do
        @tc.assert_equal nil, nil
      end
    end
  end

  def test_assert_equal_does_not_allow_lhs_nil_triggered
    assert_triggered "Expected: nil\n  Actual: false" do
      @tc.assert_equal nil, false
    end
  end

  def test_assert_in_delta
    @tc.assert_in_delta 0.0, 1.0 / 1000, 0.1
  end

  def test_delta_consistency
    @assertion_count = 2

    @tc.assert_in_delta 0, 1, 1

    assert_triggered "Expected |0 - 1| (1) to not be <= 1." do
      @tc.refute_in_delta 0, 1, 1
    end
  end

  def test_assert_in_delta_triggered
    x = maglev? ? "9.999999xxxe-07" : "1.0e-06"
    assert_triggered "Expected |0.0 - 0.001| (0.001) to be <= #{x}." do
      @tc.assert_in_delta 0.0, 1.0 / 1000, 0.000001
    end
  end

  def test_assert_in_epsilon
    @assertion_count = 10

    @tc.assert_in_epsilon 10_000, 9991
    @tc.assert_in_epsilon 9991, 10_000
    @tc.assert_in_epsilon 1.0, 1.001
    @tc.assert_in_epsilon 1.001, 1.0

    @tc.assert_in_epsilon 10_000, 9999.1, 0.0001
    @tc.assert_in_epsilon 9999.1, 10_000, 0.0001
    @tc.assert_in_epsilon 1.0, 1.0001, 0.0001
    @tc.assert_in_epsilon 1.0001, 1.0, 0.0001

    @tc.assert_in_epsilon(-1, -1)
    @tc.assert_in_epsilon(-10_000, -9991)
  end

  def test_epsilon_consistency
    @assertion_count = 2

    @tc.assert_in_epsilon 1.0, 1.001

    msg = "Expected |1.0 - 1.001| (0.000999xxx) to not be <= 0.001."
    assert_triggered msg do
      @tc.refute_in_epsilon 1.0, 1.001
    end
  end

  def test_assert_in_epsilon_triggered
    assert_triggered "Expected |10000 - 9990| (10) to be <= 9.99." do
      @tc.assert_in_epsilon 10_000, 9990
    end
  end

  def test_assert_in_epsilon_triggered_negative_case
    x = (RUBY18 and not maglev?) ? "0.1" : "0.100000xxx"
    y = maglev? ? "0.100000xxx" : "0.1"
    assert_triggered "Expected |-1.1 - -1| (#{x}) to be <= #{y}." do
      @tc.assert_in_epsilon(-1.1, -1, 0.1)
    end
  end

  def test_assert_includes
    @assertion_count = 2

    @tc.assert_includes [true], true
  end

  def test_assert_includes_triggered
    @assertion_count = 3

    e = @tc.assert_raises Minitest::Assertion do
      @tc.assert_includes [true], false
    end

    expected = "Expected [true] to include false."
    assert_equal expected, e.message
  end

  def test_assert_instance_of
    @tc.assert_instance_of String, "blah"
  end

  def test_assert_instance_of_triggered
    assert_triggered 'Expected "blah" to be an instance of Array, not String.' do
      @tc.assert_instance_of Array, "blah"
    end
  end

  def test_assert_kind_of
    @tc.assert_kind_of String, "blah"
  end

  def test_assert_kind_of_triggered
    assert_triggered 'Expected "blah" to be a kind of Array, not String.' do
      @tc.assert_kind_of Array, "blah"
    end
  end

  def test_assert_match
    @assertion_count = 2
    @tc.assert_match(/\w+/, "blah blah blah")
  end

  def test_assert_match_matcher_object
    @assertion_count = 2

    pattern = Object.new
    def pattern.=~ _; true end

    @tc.assert_match pattern, 5
  end

  def test_assert_match_matchee_to_str
    @assertion_count = 2

    obj = Object.new
    def obj.to_str; "blah" end

    @tc.assert_match "blah", obj
  end

  def test_assert_match_object_triggered
    @assertion_count = 2

    pattern = Object.new
    def pattern.=~ _; false end
    def pattern.inspect; "[Object]" end

    assert_triggered "Expected [Object] to match 5." do
      @tc.assert_match pattern, 5
    end
  end

  def test_assert_match_triggered
    @assertion_count = 2
    assert_triggered 'Expected /\d+/ to match "blah blah blah".' do
      @tc.assert_match(/\d+/, "blah blah blah")
    end
  end

  def test_assert_nil
    @tc.assert_nil nil
  end

  def test_assert_nil_triggered
    assert_triggered "Expected 42 to be nil." do
      @tc.assert_nil 42
    end
  end

  def test_assert_operator
    @tc.assert_operator 2, :>, 1
  end

  def test_assert_operator_bad_object
    bad = Object.new
    def bad.== _; true end

    @tc.assert_operator bad, :equal?, bad
  end

  def test_assert_operator_triggered
    assert_triggered "Expected 2 to be < 1." do
      @tc.assert_operator 2, :<, 1
    end
  end

  def test_assert_output_both
    @assertion_count = 2

    @tc.assert_output "yay", "blah" do
      print "yay"
      $stderr.print "blah"
    end
  end

  def test_assert_output_both_regexps
    @assertion_count = 4

    @tc.assert_output(/y.y/, /bl.h/) do
      print "yay"
      $stderr.print "blah"
    end
  end

  def test_assert_output_err
    @tc.assert_output nil, "blah" do
      $stderr.print "blah"
    end
  end

  def test_assert_output_neither
    @assertion_count = 0

    @tc.assert_output do
      # do nothing
    end
  end

  def test_assert_output_out
    @tc.assert_output "blah" do
      print "blah"
    end
  end

  def test_assert_output_triggered_both
    assert_triggered util_msg("blah", "blah blah", "In stderr") do
      @tc.assert_output "yay", "blah" do
        print "boo"
        $stderr.print "blah blah"
      end
    end
  end

  def test_assert_output_triggered_err
    assert_triggered util_msg("blah", "blah blah", "In stderr") do
      @tc.assert_output nil, "blah" do
        $stderr.print "blah blah"
      end
    end
  end

  def test_assert_output_triggered_out
    assert_triggered util_msg("blah", "blah blah", "In stdout") do
      @tc.assert_output "blah" do
        print "blah blah"
      end
    end
  end

  def test_assert_predicate
    @tc.assert_predicate "", :empty?
  end

  def test_assert_predicate_triggered
    assert_triggered 'Expected "blah" to be empty?.' do
      @tc.assert_predicate "blah", :empty?
    end
  end

  def test_assert_raises
    @tc.assert_raises RuntimeError do
      raise "blah"
    end
  end

  def test_assert_raises_default
    @tc.assert_raises do
      raise StandardError, "blah"
    end
  end

  def test_assert_raises_default_triggered
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises do
        raise SomeError, "blah"
      end
    end

    expected = clean <<-EOM.chomp
      [StandardError] exception expected, not
      Class: <SomeError>
      Message: <\"blah\">
      ---Backtrace---
      FILE:LINE:in \`test_assert_raises_default_triggered\'
      ---------------
    EOM

    actual = e.message.gsub(/^.+:\d+/, "FILE:LINE")
    actual.gsub!(/block \(\d+ levels\) in /, "") if RUBY_VERSION >= "1.9.0"

    assert_equal expected, actual
  end

  def test_assert_raises_module
    @tc.assert_raises MyModule do
      raise AnError
    end
  end

  ##
  # *sigh* This is quite an odd scenario, but it is from real (albeit
  # ugly) test code in ruby-core:
  #
  # http://svn.ruby-lang.org/cgi-bin/viewvc.cgi?view=rev&revision=29259

  def test_assert_raises_skip
    @assertion_count = 0

    assert_triggered "skipped", Minitest::Skip do
      @tc.assert_raises ArgumentError do
        begin
          raise "blah"
        rescue
          skip "skipped"
        end
      end
    end
  end

  def test_assert_raises_triggered_different
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises RuntimeError do
        raise SyntaxError, "icky"
      end
    end

    expected = clean <<-EOM.chomp
      [RuntimeError] exception expected, not
      Class: <SyntaxError>
      Message: <\"icky\">
      ---Backtrace---
      FILE:LINE:in \`test_assert_raises_triggered_different\'
      ---------------
    EOM

    actual = e.message.gsub(/^.+:\d+/, "FILE:LINE")
    actual.gsub!(/block \(\d+ levels\) in /, "") if RUBY_VERSION >= "1.9.0"

    assert_equal expected, actual
  end

  def test_assert_raises_triggered_different_msg
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises RuntimeError, "XXX" do
        raise SyntaxError, "icky"
      end
    end

    expected = clean <<-EOM
      XXX.
      [RuntimeError] exception expected, not
      Class: <SyntaxError>
      Message: <\"icky\">
      ---Backtrace---
      FILE:LINE:in \`test_assert_raises_triggered_different_msg\'
      ---------------
    EOM

    actual = e.message.gsub(/^.+:\d+/, "FILE:LINE")
    actual.gsub!(/block \(\d+ levels\) in /, "") if RUBY_VERSION >= "1.9.0"

    assert_equal expected.chomp, actual
  end

  def test_assert_raises_triggered_none
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises Minitest::Assertion do
        # do nothing
      end
    end

    expected = "Minitest::Assertion expected but nothing was raised."

    assert_equal expected, e.message
  end

  def test_assert_raises_triggered_none_msg
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises Minitest::Assertion, "XXX" do
        # do nothing
      end
    end

    expected = "XXX.\nMinitest::Assertion expected but nothing was raised."

    assert_equal expected, e.message
  end

  def test_assert_raises_subclass
    @tc.assert_raises StandardError do
      raise AnError
    end
  end

  def test_assert_raises_subclass_triggered
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises SomeError do
        raise AnError, "some message"
      end
    end

    expected = clean <<-EOM
      [SomeError] exception expected, not
      Class: <AnError>
      Message: <\"some message\">
      ---Backtrace---
      FILE:LINE:in \`test_assert_raises_subclass_triggered\'
      ---------------
    EOM

    actual = e.message.gsub(/^.+:\d+/, "FILE:LINE")
    actual.gsub!(/block \(\d+ levels\) in /, "") if RUBY_VERSION >= "1.9.0"

    assert_equal expected.chomp, actual
  end

  def test_assert_raises_exit
    @tc.assert_raises SystemExit do
      exit 1
    end
  end

  def test_assert_raises_signals
    @tc.assert_raises SignalException do
      raise SignalException, :INT
    end
  end

  def test_assert_respond_to
    @tc.assert_respond_to "blah", :empty?
  end

  def test_assert_respond_to_triggered
    assert_triggered 'Expected "blah" (String) to respond to #rawr!.' do
      @tc.assert_respond_to "blah", :rawr!
    end
  end

  def test_assert_same
    @assertion_count = 3

    o = "blah"
    @tc.assert_same 1, 1
    @tc.assert_same :blah, :blah
    @tc.assert_same o, o
  end

  def test_assert_same_triggered
    @assertion_count = 2

    assert_triggered "Expected 2 (oid=N) to be the same as 1 (oid=N)." do
      @tc.assert_same 1, 2
    end

    s1 = "blah"
    s2 = "blah"

    assert_triggered 'Expected "blah" (oid=N) to be the same as "blah" (oid=N).' do
      @tc.assert_same s1, s2
    end
  end

  def assert_deprecated name
    dep = /DEPRECATED: #{name}. From #{__FILE__}:\d+(?::.*)?/
    dep = "" if $-w.nil?

    assert_output nil, dep do
      yield
    end
  end

  def test_assert_send
    assert_deprecated :assert_send do
      @tc.assert_send [1, :<, 2]
    end
  end

  def test_assert_send_bad
    assert_deprecated :assert_send do
      assert_triggered "Expected 1.>(*[2]) to return true." do
        @tc.assert_send [1, :>, 2]
      end
    end
  end

  def test_assert_silent
    @assertion_count = 2

    @tc.assert_silent do
      # do nothing
    end
  end

  def test_assert_silent_triggered_err
    assert_triggered util_msg("", "blah blah", "In stderr") do
      @tc.assert_silent do
        $stderr.print "blah blah"
      end
    end
  end

  def test_assert_silent_triggered_out
    @assertion_count = 2

    assert_triggered util_msg("", "blah blah", "In stdout") do
      @tc.assert_silent do
        print "blah blah"
      end
    end
  end

  def test_assert_throws
    @tc.assert_throws :blah do
      throw :blah
    end
  end

  def test_assert_throws_name_error
    @tc.assert_raises NameError do
      @tc.assert_throws :blah do
        raise NameError
      end
    end
  end

  def test_assert_throws_argument_exception
    @tc.assert_raises ArgumentError do
      @tc.assert_throws :blah do
        raise ArgumentError
      end
    end
  end

  def test_assert_throws_different
    assert_triggered "Expected :blah to have been thrown, not :not_blah." do
      @tc.assert_throws :blah do
        throw :not_blah
      end
    end
  end

  def test_assert_throws_unthrown
    assert_triggered "Expected :blah to have been thrown." do
      @tc.assert_throws :blah do
        # do nothing
      end
    end
  end

  def test_capture_io
    @assertion_count = 0

    non_verbose do
      out, err = capture_io do
        puts "hi"
        $stderr.puts "bye!"
      end

      assert_equal "hi\n", out
      assert_equal "bye!\n", err
    end
  end

  def test_capture_subprocess_io
    @assertion_count = 0

    non_verbose do
      out, err = capture_subprocess_io do
        system("echo hi")
        system("echo bye! 1>&2")
      end

      assert_equal "hi\n", out
      assert_equal "bye!", err.strip
    end
  end

  def test_class_asserts_match_refutes
    @assertion_count = 0

    methods = Minitest::Assertions.public_instance_methods
    methods.map!(&:to_s) if Symbol === methods.first

    # These don't have corresponding refutes _on purpose_. They're
    # useless and will never be added, so don't bother.
    ignores = %w[assert_output assert_raises assert_send
                 assert_silent assert_throws assert_mock]

    # These are test/unit methods. I'm not actually sure why they're still here
    ignores += %w[assert_no_match assert_not_equal assert_not_nil
                  assert_not_same assert_nothing_raised
                  assert_nothing_thrown assert_raise]

    asserts = methods.grep(/^assert/).sort - ignores
    refutes = methods.grep(/^refute/).sort - ignores

    assert_empty refutes.map { |n| n.sub(/^refute/, "assert") } - asserts
    assert_empty asserts.map { |n| n.sub(/^assert/, "refute") } - refutes
  end

  def test_flunk
    assert_triggered "Epic Fail!" do
      @tc.flunk
    end
  end

  def test_flunk_message
    assert_triggered @zomg do
      @tc.flunk @zomg
    end
  end

  def test_message
    @assertion_count = 0

    assert_equal "blah2.",         @tc.message          { "blah2" }.call
    assert_equal "blah2.",         @tc.message("")      { "blah2" }.call
    assert_equal "blah1.\nblah2.", @tc.message(:blah1)  { "blah2" }.call
    assert_equal "blah1.\nblah2.", @tc.message("blah1") { "blah2" }.call

    message = proc { "blah1" }
    assert_equal "blah1.\nblah2.", @tc.message(message) { "blah2" }.call

    message = @tc.message { "blah1" }
    assert_equal "blah1.\nblah2.", @tc.message(message) { "blah2" }.call
  end

  def test_message_message
    assert_triggered "whoops.\nExpected: 1\n  Actual: 2" do
      @tc.assert_equal 1, 2, message { "whoops" }
    end
  end

  def test_message_lambda
    assert_triggered "whoops.\nExpected: 1\n  Actual: 2" do
      @tc.assert_equal 1, 2, lambda { "whoops" }
    end
  end

  def test_message_deferred
    @assertion_count, var = 0, nil

    msg = message { var = "blah" }

    assert_nil var

    msg.call

    assert_equal "blah", var
  end

  def test_pass
    @tc.pass
  end

  def test_prints
    printer = Class.new { extend Minitest::Assertions }
    @tc.assert_equal '"test"', printer.mu_pp(ImmutableString.new "test")
  end

  def test_refute
    @assertion_count = 2

    @tc.assert_equal false, @tc.refute(false), "returns false on success"
  end

  def test_refute_empty
    @assertion_count = 2

    @tc.refute_empty [1]
  end

  def test_refute_empty_triggered
    @assertion_count = 2

    assert_triggered "Expected [] to not be empty." do
      @tc.refute_empty []
    end
  end

  def test_refute_equal
    @tc.refute_equal "blah", "yay"
  end

  def test_refute_equal_triggered
    assert_triggered 'Expected "blah" to not be equal to "blah".' do
      @tc.refute_equal "blah", "blah"
    end
  end

  def test_refute_in_delta
    @tc.refute_in_delta 0.0, 1.0 / 1000, 0.000001
  end

  def test_refute_in_delta_triggered
    x = maglev? ? "0.100000xxx" : "0.1"
    assert_triggered "Expected |0.0 - 0.001| (0.001) to not be <= #{x}." do
      @tc.refute_in_delta 0.0, 1.0 / 1000, 0.1
    end
  end

  def test_refute_in_epsilon
    @tc.refute_in_epsilon 10_000, 9990-1
  end

  def test_refute_in_epsilon_triggered
    assert_triggered "Expected |10000 - 9990| (10) to not be <= 10.0." do
      @tc.refute_in_epsilon 10_000, 9990
      flunk
    end
  end

  def test_refute_includes
    @assertion_count = 2

    @tc.refute_includes [true], false
  end

  def test_refute_includes_triggered
    @assertion_count = 3

    e = @tc.assert_raises Minitest::Assertion do
      @tc.refute_includes [true], true
    end

    expected = "Expected [true] to not include true."
    assert_equal expected, e.message
  end

  def test_refute_instance_of
    @tc.refute_instance_of Array, "blah"
  end

  def test_refute_instance_of_triggered
    assert_triggered 'Expected "blah" to not be an instance of String.' do
      @tc.refute_instance_of String, "blah"
    end
  end

  def test_refute_kind_of
    @tc.refute_kind_of Array, "blah"
  end

  def test_refute_kind_of_triggered
    assert_triggered 'Expected "blah" to not be a kind of String.' do
      @tc.refute_kind_of String, "blah"
    end
  end

  def test_refute_match
    @assertion_count = 2
    @tc.refute_match(/\d+/, "blah blah blah")
  end

  def test_refute_match_matcher_object
    @assertion_count = 2
    @tc.refute_match Object.new, 5 # default #=~ returns false
  end

  def test_refute_match_object_triggered
    @assertion_count = 2

    pattern = Object.new
    def pattern.=~ _; true end
    def pattern.inspect; "[Object]" end

    assert_triggered "Expected [Object] to not match 5." do
      @tc.refute_match pattern, 5
    end
  end

  def test_refute_match_triggered
    @assertion_count = 2
    assert_triggered 'Expected /\w+/ to not match "blah blah blah".' do
      @tc.refute_match(/\w+/, "blah blah blah")
    end
  end

  def test_refute_nil
    @tc.refute_nil 42
  end

  def test_refute_nil_triggered
    assert_triggered "Expected nil to not be nil." do
      @tc.refute_nil nil
    end
  end

  def test_refute_predicate
    @tc.refute_predicate "42", :empty?
  end

  def test_refute_predicate_triggered
    assert_triggered 'Expected "" to not be empty?.' do
      @tc.refute_predicate "", :empty?
    end
  end

  def test_refute_operator
    @tc.refute_operator 2, :<, 1
  end

  def test_refute_operator_bad_object
    bad = Object.new
    def bad.== _; true end

    @tc.refute_operator true, :equal?, bad
  end

  def test_refute_operator_triggered
    assert_triggered "Expected 2 to not be > 1." do
      @tc.refute_operator 2, :>, 1
    end
  end

  def test_refute_respond_to
    @tc.refute_respond_to "blah", :rawr!
  end

  def test_refute_respond_to_triggered
    assert_triggered 'Expected "blah" to not respond to empty?.' do
      @tc.refute_respond_to "blah", :empty?
    end
  end

  def test_refute_same
    @tc.refute_same 1, 2
  end

  def test_refute_same_triggered
    assert_triggered "Expected 1 (oid=N) to not be the same as 1 (oid=N)." do
      @tc.refute_same 1, 1
    end
  end

  def test_skip
    @assertion_count = 0

    assert_triggered "haha!", Minitest::Skip do
      @tc.skip "haha!"
    end
  end

  def test_runnable_methods_random
    @assertion_count = 0

    sample_test_case = Class.new FakeNamedTest do
      def self.test_order; :random; end
      def test_test1; assert "does not matter" end
      def test_test2; assert "does not matter" end
      def test_test3; assert "does not matter" end
    end

    srand 42
    expected = case
               when maglev? then
                 %w[test_test2 test_test3 test_test1]
               else
                 %w[test_test2 test_test1 test_test3]
               end
    assert_equal expected, sample_test_case.runnable_methods
  end

  def test_runnable_methods_sorted
    @assertion_count = 0

    sample_test_case = Class.new FakeNamedTest do
      def self.test_order; :sorted end
      def test_test3; assert "does not matter" end
      def test_test2; assert "does not matter" end
      def test_test1; assert "does not matter" end
    end

    expected = %w[test_test1 test_test2 test_test3]
    assert_equal expected, sample_test_case.runnable_methods
  end

  def test_i_suck_and_my_tests_are_order_dependent_bang_sets_test_order_alpha
    @assertion_count = 0

    shitty_test_case = Class.new FakeNamedTest

    shitty_test_case.i_suck_and_my_tests_are_order_dependent!

    assert_equal :alpha, shitty_test_case.test_order
  end

  def test_i_suck_and_my_tests_are_order_dependent_bang_does_not_warn
    @assertion_count = 0

    shitty_test_case = Class.new FakeNamedTest

    def shitty_test_case.test_order; :lol end

    assert_silent do
      shitty_test_case.i_suck_and_my_tests_are_order_dependent!
    end
  end

  def assert_triggered expected, klass = Minitest::Assertion
    e = assert_raises klass do
      yield
    end

    msg = e.message.sub(/(---Backtrace---).*/m, '\1')
    msg.gsub!(/\(oid=[-0-9]+\)/, "(oid=N)")
    msg.gsub!(/(\d\.\d{6})\d+/, '\1xxx') # normalize: ruby version, impl, platform

    assert_msg = Regexp === expected ? :assert_match : :assert_equal
    self.send assert_msg, expected, msg
  end

  def util_msg exp, act, msg = nil
    s = "Expected: #{exp.inspect}\n  Actual: #{act.inspect}"
    s = "#{msg}.\n#{s}" if msg
    s
  end

  def without_diff
    old_diff = Minitest::Assertions.diff
    Minitest::Assertions.diff = nil

    yield
  ensure
    Minitest::Assertions.diff = old_diff
  end
end

class TestMinitestGuard < Minitest::Test
  parallelize_me!

  def test_mri_eh
    assert self.class.mri? "ruby blah"
    assert self.mri? "ruby blah"
  end

  def test_jruby_eh
    assert self.class.jruby? "java"
    assert self.jruby? "java"
  end

  def test_rubinius_eh
    assert self.class.rubinius? "rbx"
    assert self.rubinius? "rbx"
  end

  def test_windows_eh
    assert self.class.windows? "mswin"
    assert self.windows? "mswin"
  end
end

class TestMinitestUnitRecording < MetaMetaMetaTestCase
  # do not parallelize this suite... it just can't handle it.

  def assert_run_record *expected, &block
    @tu = Class.new FakeNamedTest, &block

    run_tu_with_fresh_reporter

    recorded = first_reporter.results.map(&:failures).flatten.map { |f| f.error.class }

    assert_equal expected, recorded
  end

  def test_run_with_bogus_reporter
    # https://github.com/seattlerb/minitest/issues/659
    # TODO: remove test for minitest 6
    @tu = Class.new FakeNamedTest do
      def test_method
        assert true
      end
    end

    bogus_reporter = Class.new do      # doesn't subclass AbstractReporter
      def start; @success = false; end
      # def prerecord klass, name; end # doesn't define full API
      def record result; @success = true; end
      def report; end
      def passed?; end
      def results; end
      def success?; @success; end
    end.new

    self.reporter = Minitest::CompositeReporter.new
    reporter << bogus_reporter

    Minitest::Runnable.runnables.delete @tu

    @tu.run reporter, {}

    assert_predicate bogus_reporter, :success?
  end

  def test_record_passing
    assert_run_record do
      def test_method
        assert true
      end
    end
  end

  def test_record_failing
    assert_run_record Minitest::Assertion do
      def test_method
        assert false
      end
    end
  end

  def test_record_error
    assert_run_record RuntimeError do
      def test_method
        raise "unhandled exception"
      end
    end
  end

  def test_record_error_teardown
    assert_run_record RuntimeError do
      def test_method
        assert true
      end

      def teardown
        raise "unhandled exception"
      end
    end
  end

  def test_record_error_in_test_and_teardown
    assert_run_record AnError, RuntimeError do
      def test_method
        raise AnError
      end

      def teardown
        raise "unhandled exception"
      end
    end
  end

  def test_to_s_error_in_test_and_teardown
    @tu = Class.new FakeNamedTest do
      def test_method
        raise AnError
      end

      def teardown
        raise "unhandled exception"
      end
    end

    run_tu_with_fresh_reporter

    exp = clean "
      Error:
      FakeNamedTestXX#test_method:
      AnError: AnError
          FILE:LINE:in `test_method'

      Error:
      FakeNamedTestXX#test_method:
      RuntimeError: unhandled exception
          FILE:LINE:in `teardown'
    "

    assert_equal exp.strip, normalize_output(first_reporter.results.first.to_s).strip
  end

  def test_record_skip
    assert_run_record Minitest::Skip do
      def test_method
        skip "not yet"
      end
    end
  end
end
