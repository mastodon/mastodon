require "optparse"
require "thread"
require "mutex_m"
require "minitest/parallel"
require "stringio"

##
# :include: README.rdoc

module Minitest
  VERSION = "5.11.3" # :nodoc:
  ENCS = "".respond_to? :encoding # :nodoc:

  @@installed_at_exit ||= false
  @@after_run = []
  @extensions = []

  mc = (class << self; self; end)

  ##
  # Parallel test executor

  mc.send :attr_accessor, :parallel_executor
  self.parallel_executor = Parallel::Executor.new((ENV["N"] || 2).to_i)

  ##
  # Filter object for backtraces.

  mc.send :attr_accessor, :backtrace_filter

  ##
  # Reporter object to be used for all runs.
  #
  # NOTE: This accessor is only available during setup, not during runs.

  mc.send :attr_accessor, :reporter

  ##
  # Names of known extension plugins.

  mc.send :attr_accessor, :extensions

  ##
  # The signal to use for dumping information to STDERR. Defaults to "INFO".

  mc.send :attr_accessor, :info_signal
  self.info_signal = "INFO"

  ##
  # Registers Minitest to run at process exit

  def self.autorun
    at_exit {
      next if $! and not ($!.kind_of? SystemExit and $!.success?)

      exit_code = nil

      at_exit {
        @@after_run.reverse_each(&:call)
        exit exit_code || false
      }

      exit_code = Minitest.run ARGV
    } unless @@installed_at_exit
    @@installed_at_exit = true
  end

  ##
  # A simple hook allowing you to run a block of code after everything
  # is done running. Eg:
  #
  #   Minitest.after_run { p $debugging_info }

  def self.after_run &block
    @@after_run << block
  end

  def self.init_plugins options # :nodoc:
    self.extensions.each do |name|
      msg = "plugin_#{name}_init"
      send msg, options if self.respond_to? msg
    end
  end

  def self.load_plugins # :nodoc:
    return unless self.extensions.empty?

    seen = {}

    require "rubygems" unless defined? Gem

    Gem.find_files("minitest/*_plugin.rb").each do |plugin_path|
      name = File.basename plugin_path, "_plugin.rb"

      next if seen[name]
      seen[name] = true

      require plugin_path
      self.extensions << name
    end
  end

  ##
  # This is the top-level run method. Everything starts from here. It
  # tells each Runnable sub-class to run, and each of those are
  # responsible for doing whatever they do.
  #
  # The overall structure of a run looks like this:
  #
  #   Minitest.autorun
  #     Minitest.run(args)
  #       Minitest.__run(reporter, options)
  #         Runnable.runnables.each
  #           runnable.run(reporter, options)
  #             self.runnable_methods.each
  #               self.run_one_method(self, runnable_method, reporter)
  #                 Minitest.run_one_method(klass, runnable_method)
  #                   klass.new(runnable_method).run

  def self.run args = []
    self.load_plugins unless args.delete("--no-plugins") || ENV["MT_NO_PLUGINS"]

    options = process_args args

    reporter = CompositeReporter.new
    reporter << SummaryReporter.new(options[:io], options)
    reporter << ProgressReporter.new(options[:io], options)

    self.reporter = reporter # this makes it available to plugins
    self.init_plugins options
    self.reporter = nil # runnables shouldn't depend on the reporter, ever

    self.parallel_executor.start if parallel_executor.respond_to?(:start)
    reporter.start
    begin
      __run reporter, options
    rescue Interrupt
      warn "Interrupted. Exiting..."
    end
    self.parallel_executor.shutdown
    reporter.report

    reporter.passed?
  end

  ##
  # Internal run method. Responsible for telling all Runnable
  # sub-classes to run.

  def self.__run reporter, options
    suites = Runnable.runnables.reject { |s| s.runnable_methods.empty? }.shuffle
    parallel, serial = suites.partition { |s| s.test_order == :parallel }

    # If we run the parallel tests before the serial tests, the parallel tests
    # could run in parallel with the serial tests. This would be bad because
    # the serial tests won't lock around Reporter#record. Run the serial tests
    # first, so that after they complete, the parallel tests will lock when
    # recording results.
    serial.map { |suite| suite.run reporter, options } +
      parallel.map { |suite| suite.run reporter, options }
  end

  def self.process_args args = [] # :nodoc:
    options = {
               :io => $stdout,
              }
    orig_args = args.dup

    OptionParser.new do |opts|
      opts.banner  = "minitest options:"
      opts.version = Minitest::VERSION

      opts.on "-h", "--help", "Display this help." do
        puts opts
        exit
      end

      opts.on "--no-plugins", "Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS)."

      desc = "Sets random seed. Also via env. Eg: SEED=n rake"
      opts.on "-s", "--seed SEED", Integer, desc do |m|
        options[:seed] = m.to_i
      end

      opts.on "-v", "--verbose", "Verbose. Show progress processing files." do
        options[:verbose] = true
      end

      opts.on "-n", "--name PATTERN", "Filter run on /regexp/ or string." do |a|
        options[:filter] = a
      end

      opts.on "-e", "--exclude PATTERN", "Exclude /regexp/ or string from run." do |a|
        options[:exclude] = a
      end

      unless extensions.empty?
        opts.separator ""
        opts.separator "Known extensions: #{extensions.join(", ")}"

        extensions.each do |meth|
          msg = "plugin_#{meth}_options"
          send msg, opts, options if self.respond_to?(msg)
        end
      end

      begin
        opts.parse! args
      rescue OptionParser::InvalidOption => e
        puts
        puts e
        puts
        puts opts
        exit 1
      end

      orig_args -= args
    end

    unless options[:seed] then
      srand
      options[:seed] = (ENV["SEED"] || srand).to_i % 0xFFFF
      orig_args << "--seed" << options[:seed].to_s
    end

    srand options[:seed]

    options[:args] = orig_args.map { |s|
      s =~ /[\s|&<>$()]/ ? s.inspect : s
    }.join " "

    options
  end

  def self.filter_backtrace bt # :nodoc:
    backtrace_filter.filter bt
  end

  ##
  # Represents anything "runnable", like Test, Spec, Benchmark, or
  # whatever you can dream up.
  #
  # Subclasses of this are automatically registered and available in
  # Runnable.runnables.

  class Runnable
    ##
    # Number of assertions executed in this run.

    attr_accessor :assertions

    ##
    # An assertion raised during the run, if any.

    attr_accessor :failures

    ##
    # The time it took to run.

    attr_accessor :time

    def time_it # :nodoc:
      t0 = Minitest.clock_time

      yield
    ensure
      self.time = Minitest.clock_time - t0
    end

    ##
    # Name of the run.

    def name
      @NAME
    end

    ##
    # Set the name of the run.

    def name= o
      @NAME = o
    end

    ##
    # Returns all instance methods matching the pattern +re+.

    def self.methods_matching re
      public_instance_methods(true).grep(re).map(&:to_s)
    end

    def self.reset # :nodoc:
      @@runnables = []
    end

    reset

    ##
    # Responsible for running all runnable methods in a given class,
    # each in its own instance. Each instance is passed to the
    # reporter to record.

    def self.run reporter, options = {}
      filter = options[:filter] || "/./"
      filter = Regexp.new $1 if filter =~ %r%/(.*)/%

      filtered_methods = self.runnable_methods.find_all { |m|
        filter === m || filter === "#{self}##{m}"
      }

      exclude = options[:exclude]
      exclude = Regexp.new $1 if exclude =~ %r%/(.*)/%

      filtered_methods.delete_if { |m|
        exclude === m || exclude === "#{self}##{m}"
      }

      return if filtered_methods.empty?

      with_info_handler reporter do
        filtered_methods.each do |method_name|
          run_one_method self, method_name, reporter
        end
      end
    end

    ##
    # Runs a single method and has the reporter record the result.
    # This was considered internal API but is factored out of run so
    # that subclasses can specialize the running of an individual
    # test. See Minitest::ParallelTest::ClassMethods for an example.

    def self.run_one_method klass, method_name, reporter
      reporter.prerecord klass, method_name
      reporter.record Minitest.run_one_method(klass, method_name)
    end

    def self.with_info_handler reporter, &block # :nodoc:
      handler = lambda do
        unless reporter.passed? then
          warn "Current results:"
          warn ""
          warn reporter.reporters.first
          warn ""
        end
      end

      on_signal ::Minitest.info_signal, handler, &block
    end

    SIGNALS = Signal.list # :nodoc:

    def self.on_signal name, action # :nodoc:
      supported = SIGNALS[name]

      old_trap = trap name do
        old_trap.call if old_trap.respond_to? :call
        action.call
      end if supported

      yield
    ensure
      trap name, old_trap if supported
    end

    ##
    # Each subclass of Runnable is responsible for overriding this
    # method to return all runnable methods. See #methods_matching.

    def self.runnable_methods
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Returns all subclasses of Runnable.

    def self.runnables
      @@runnables
    end

    @@marshal_dump_warned = false

    def marshal_dump # :nodoc:
      unless @@marshal_dump_warned then
        warn ["Minitest::Runnable#marshal_dump is deprecated.",
              "You might be violating internals. From", caller.first].join " "
        @@marshal_dump_warned = true
      end

      [self.name, self.failures, self.assertions, self.time]
    end

    def marshal_load ary # :nodoc:
      self.name, self.failures, self.assertions, self.time = ary
    end

    def failure # :nodoc:
      self.failures.first
    end

    def initialize name # :nodoc:
      self.name       = name
      self.failures   = []
      self.assertions = 0
    end

    ##
    # Runs a single method. Needs to return self.

    def run
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Did this run pass?
    #
    # Note: skipped runs are not considered passing, but they don't
    # cause the process to exit non-zero.

    def passed?
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Returns a single character string to print based on the result
    # of the run. Eg ".", "F", or "E".

    def result_code
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Was this run skipped? See #passed? for more information.

    def skipped?
      raise NotImplementedError, "subclass responsibility"
    end
  end

  ##
  # Shared code for anything that can get passed to a Reporter. See
  # Minitest::Test & Minitest::Result.

  module Reportable
    ##
    # Did this run pass?
    #
    # Note: skipped runs are not considered passing, but they don't
    # cause the process to exit non-zero.

    def passed?
      not self.failure
    end

    ##
    # The location identifier of this test. Depends on a method
    # existing called class_name.

    def location
      loc = " [#{self.failure.location}]" unless passed? or error?
      "#{self.class_name}##{self.name}#{loc}"
    end

    def class_name # :nodoc:
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Returns ".", "F", or "E" based on the result of the run.

    def result_code
      self.failure and self.failure.result_code or "."
    end

    ##
    # Was this run skipped?

    def skipped?
      self.failure and Skip === self.failure
    end

    ##
    # Did this run error?

    def error?
      self.failures.any? { |f| UnexpectedError === f }
    end
  end

  ##
  # This represents a test result in a clean way that can be
  # marshalled over a wire. Tests can do anything they want to the
  # test instance and can create conditions that cause Marshal.dump to
  # blow up. By using Result.from(a_test) you can be reasonably sure
  # that the test result can be marshalled.

  class Result < Runnable
    include Minitest::Reportable

    undef_method :marshal_dump
    undef_method :marshal_load

    ##
    # The class name of the test result.

    attr_accessor :klass

    ##
    # The location of the test method.

    attr_accessor :source_location

    ##
    # Create a new test result from a Runnable instance.

    def self.from runnable
      o = runnable

      r = self.new o.name
      r.klass      = o.class.name
      r.assertions = o.assertions
      r.failures   = o.failures.dup
      r.time       = o.time

      r.source_location = o.method(o.name).source_location rescue ["unknown", -1]

      r
    end

    def class_name # :nodoc:
      self.klass # for Minitest::Reportable
    end

    def to_s # :nodoc:
      return location if passed? and not skipped?

      failures.map { |failure|
        "#{failure.result_label}:\n#{self.location}:\n#{failure.message}\n"
      }.join "\n"
    end
  end

  ##
  # Defines the API for Reporters. Subclass this and override whatever
  # you want. Go nuts.

  class AbstractReporter
    include Mutex_m

    ##
    # Starts reporting on the run.

    def start
    end

    ##
    # About to start running a test. This allows a reporter to show
    # that it is starting or that we are in the middle of a test run.

    def prerecord klass, name
    end

    ##
    # Record a result and output the Runnable#result_code. Stores the
    # result of the run if the run did not pass.

    def record result
    end

    ##
    # Outputs the summary of the run.

    def report
    end

    ##
    # Did this run pass?

    def passed?
      true
    end
  end

  class Reporter < AbstractReporter # :nodoc:
    ##
    # The IO used to report.

    attr_accessor :io

    ##
    # Command-line options for this run.

    attr_accessor :options

    def initialize io = $stdout, options = {} # :nodoc:
      super()
      self.io      = io
      self.options = options
    end
  end

  ##
  # A very simple reporter that prints the "dots" during the run.
  #
  # This is added to the top-level CompositeReporter at the start of
  # the run. If you want to change the output of minitest via a
  # plugin, pull this out of the composite and replace it with your
  # own.

  class ProgressReporter < Reporter
    def prerecord klass, name #:nodoc:
      if options[:verbose] then
        io.print "%s#%s = " % [klass.name, name]
        io.flush
      end
    end

    def record result # :nodoc:
      io.print "%.2f s = " % [result.time] if options[:verbose]
      io.print result.result_code
      io.puts if options[:verbose]
    end
  end

  ##
  # A reporter that gathers statistics about a test run. Does not do
  # any IO because meant to be used as a parent class for a reporter
  # that does.
  #
  # If you want to create an entirely different type of output (eg,
  # CI, HTML, etc), this is the place to start.

  class StatisticsReporter < Reporter
    # :stopdoc:
    attr_accessor :assertions
    attr_accessor :count
    attr_accessor :results
    attr_accessor :start_time
    attr_accessor :total_time
    attr_accessor :failures
    attr_accessor :errors
    attr_accessor :skips
    # :startdoc:

    def initialize io = $stdout, options = {} # :nodoc:
      super

      self.assertions = 0
      self.count      = 0
      self.results    = []
      self.start_time = nil
      self.total_time = nil
      self.failures   = nil
      self.errors     = nil
      self.skips      = nil
    end

    def passed? # :nodoc:
      results.all?(&:skipped?)
    end

    def start # :nodoc:
      self.start_time = Minitest.clock_time
    end

    def record result # :nodoc:
      self.count += 1
      self.assertions += result.assertions

      results << result if not result.passed? or result.skipped?
    end

    def report # :nodoc:
      aggregate = results.group_by { |r| r.failure.class }
      aggregate.default = [] # dumb. group_by should provide this

      self.total_time = Minitest.clock_time - start_time
      self.failures   = aggregate[Assertion].size
      self.errors     = aggregate[UnexpectedError].size
      self.skips      = aggregate[Skip].size
    end
  end

  ##
  # A reporter that prints the header, summary, and failure details at
  # the end of the run.
  #
  # This is added to the top-level CompositeReporter at the start of
  # the run. If you want to change the output of minitest via a
  # plugin, pull this out of the composite and replace it with your
  # own.

  class SummaryReporter < StatisticsReporter
    # :stopdoc:
    attr_accessor :sync
    attr_accessor :old_sync
    # :startdoc:

    def start # :nodoc:
      super

      io.puts "Run options: #{options[:args]}"
      io.puts
      io.puts "# Running:"
      io.puts

      self.sync = io.respond_to? :"sync=" # stupid emacs
      self.old_sync, io.sync = io.sync, true if self.sync
    end

    def report # :nodoc:
      super

      io.sync = self.old_sync

      io.puts unless options[:verbose] # finish the dots
      io.puts
      io.puts statistics
      aggregated_results io
      io.puts summary
    end

    def statistics # :nodoc:
      "Finished in %.6fs, %.4f runs/s, %.4f assertions/s." %
        [total_time, count / total_time, assertions / total_time]
    end

    def aggregated_results io # :nodoc:
      filtered_results = results.dup
      filtered_results.reject!(&:skipped?) unless options[:verbose]

      filtered_results.each_with_index { |result, i|
        io.puts "\n%3d) %s" % [i+1, result]
      }
      io.puts
      io
    end

    def to_s # :nodoc:
      aggregated_results(StringIO.new(binary_string)).string
    end

    def summary # :nodoc:
      extra = ""

      extra = "\n\nYou have skipped tests. Run with --verbose for details." if
        results.any?(&:skipped?) unless options[:verbose] or ENV["MT_NO_SKIP_MSG"]

      "%d runs, %d assertions, %d failures, %d errors, %d skips%s" %
        [count, assertions, failures, errors, skips, extra]
    end

    private

    if '<3'.respond_to? :b
      def binary_string; ''.b; end
    else
      def binary_string; ''.force_encoding(Encoding::ASCII_8BIT); end
    end
  end

  ##
  # Dispatch to multiple reporters as one.

  class CompositeReporter < AbstractReporter
    ##
    # The list of reporters to dispatch to.

    attr_accessor :reporters

    def initialize *reporters # :nodoc:
      super()
      self.reporters = reporters
    end

    def io # :nodoc:
      reporters.first.io
    end

    ##
    # Add another reporter to the mix.

    def << reporter
      self.reporters << reporter
    end

    def passed? # :nodoc:
      self.reporters.all?(&:passed?)
    end

    def start # :nodoc:
      self.reporters.each(&:start)
    end

    def prerecord klass, name # :nodoc:
      self.reporters.each do |reporter|
        # TODO: remove conditional for minitest 6
        reporter.prerecord klass, name if reporter.respond_to? :prerecord
      end
    end

    def record result # :nodoc:
      self.reporters.each do |reporter|
        reporter.record result
      end
    end

    def report # :nodoc:
      self.reporters.each(&:report)
    end
  end

  ##
  # Represents run failures.

  class Assertion < Exception
    def error # :nodoc:
      self
    end

    ##
    # Where was this run before an assertion was raised?

    def location
      last_before_assertion = ""
      self.backtrace.reverse_each do |s|
        break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      last_before_assertion.sub(/:in .*$/, "")
    end

    def result_code # :nodoc:
      result_label[0, 1]
    end

    def result_label # :nodoc:
      "Failure"
    end
  end

  ##
  # Assertion raised when skipping a run.

  class Skip < Assertion
    def result_label # :nodoc:
      "Skipped"
    end
  end

  ##
  # Assertion wrapping an unexpected error that was raised during a run.

  class UnexpectedError < Assertion
    attr_accessor :exception # :nodoc:

    def initialize exception # :nodoc:
      super "Unexpected exception"
      self.exception = exception
    end

    def backtrace # :nodoc:
      self.exception.backtrace
    end

    def error # :nodoc:
      self.exception
    end

    def message # :nodoc:
      bt = Minitest.filter_backtrace(self.backtrace).join "\n    "
      "#{self.exception.class}: #{self.exception.message}\n    #{bt}"
    end

    def result_label # :nodoc:
      "Error"
    end
  end

  ##
  # Provides a simple set of guards that you can use in your tests
  # to skip execution if it is not applicable. These methods are
  # mixed into Test as both instance and class methods so you
  # can use them inside or outside of the test methods.
  #
  #   def test_something_for_mri
  #     skip "bug 1234"  if jruby?
  #     # ...
  #   end
  #
  #   if windows? then
  #     # ... lots of test methods ...
  #   end

  module Guard

    ##
    # Is this running on jruby?

    def jruby? platform = RUBY_PLATFORM
      "java" == platform
    end

    ##
    # Is this running on maglev?

    def maglev? platform = defined?(RUBY_ENGINE) && RUBY_ENGINE
      "maglev" == platform
    end

    ##
    # Is this running on mri?

    def mri? platform = RUBY_DESCRIPTION
      /^ruby/ =~ platform
    end

    ##
    # Is this running on rubinius?

    def rubinius? platform = defined?(RUBY_ENGINE) && RUBY_ENGINE
      "rbx" == platform
    end

    ##
    # Is this running on windows?

    def windows? platform = RUBY_PLATFORM
      /mswin|mingw/ =~ platform
    end
  end

  ##
  # The standard backtrace filter for minitest.
  #
  # See Minitest.backtrace_filter=.

  class BacktraceFilter

    MT_RE = %r%lib/minitest% #:nodoc:

    ##
    # Filter +bt+ to something useful. Returns the whole thing if $DEBUG.

    def filter bt
      return ["No backtrace"] unless bt

      return bt.dup if $DEBUG

      new_bt = bt.take_while { |line| line !~ MT_RE }
      new_bt = bt.select     { |line| line !~ MT_RE } if new_bt.empty?
      new_bt = bt.dup                                 if new_bt.empty?

      new_bt
    end
  end

  self.backtrace_filter = BacktraceFilter.new

  def self.run_one_method klass, method_name # :nodoc:
    result = klass.new(method_name).run
    raise "#{klass}#run _must_ return a Result" unless Result === result
    result
  end

  # :stopdoc:

  if defined? Process::CLOCK_MONOTONIC # :nodoc:
    def self.clock_time
      Process.clock_gettime Process::CLOCK_MONOTONIC
    end
  else
    def self.clock_time
      Time.now
    end
  end

  class Runnable # re-open
    def self.inherited klass # :nodoc:
      self.runnables << klass
      super
    end
  end

  # :startdoc:
end

require "minitest/test"
