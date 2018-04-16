# frozen_string_literal: true
require "rake"
require "rake/tasklib"

module Rake

  # Create a task that runs a set of tests.
  #
  # Example:
  #   require "rake/testtask"
  #
  #   Rake::TestTask.new do |t|
  #     t.libs << "test"
  #     t.test_files = FileList['test/test*.rb']
  #     t.verbose = true
  #   end
  #
  # If rake is invoked with a "TEST=filename" command line option,
  # then the list of test files will be overridden to include only the
  # filename specified on the command line.  This provides an easy way
  # to run just one test.
  #
  # If rake is invoked with a "TESTOPTS=options" command line option,
  # then the given options are passed to the test process after a
  # '--'.  This allows Test::Unit options to be passed to the test
  # suite.
  #
  # Examples:
  #
  #   rake test                           # run tests normally
  #   rake test TEST=just_one_file.rb     # run just one test file.
  #   rake test TESTOPTS="-v"             # run in verbose mode
  #   rake test TESTOPTS="--runner=fox"   # use the fox test runner
  #
  class TestTask < TaskLib

    # Name of test task. (default is :test)
    attr_accessor :name

    # List of directories added to $LOAD_PATH before running the
    # tests. (default is 'lib')
    attr_accessor :libs

    # True if verbose test output desired. (default is false)
    attr_accessor :verbose

    # Test options passed to the test suite.  An explicit
    # TESTOPTS=opts on the command line will override this. (default
    # is NONE)
    attr_accessor :options

    # Request that the tests be run with the warning flag set.
    # E.g. warning=true implies "ruby -w" used to run the tests.
    # (default is true)
    attr_accessor :warning

    # Glob pattern to match test files. (default is 'test/test*.rb')
    attr_accessor :pattern

    # Style of test loader to use.  Options are:
    #
    # * :rake -- Rake provided test loading script (default).
    # * :testrb -- Ruby provided test loading script.
    # * :direct -- Load tests using command line loader.
    #
    attr_accessor :loader

    # Array of command line options to pass to ruby when running test loader.
    attr_accessor :ruby_opts

    # Description of the test task. (default is 'Run tests')
    attr_accessor :description

    # Task prerequisites.
    attr_accessor :deps

    # Explicitly define the list of test files to be included in a
    # test.  +list+ is expected to be an array of file names (a
    # FileList is acceptable).  If both +pattern+ and +test_files+ are
    # used, then the list of test files is the union of the two.
    def test_files=(list)
      @test_files = list
    end

    # Create a testing task.
    def initialize(name=:test)
      @name = name
      @libs = ["lib"]
      @pattern = nil
      @options = nil
      @test_files = nil
      @verbose = false
      @warning = true
      @loader = :rake
      @ruby_opts = []
      @description = "Run tests" + (@name == :test ? "" : " for #{@name}")
      @deps = []
      if @name.is_a?(Hash)
        @deps = @name.values.first
        @name = @name.keys.first
      end
      yield self if block_given?
      @pattern = "test/test*.rb" if @pattern.nil? && @test_files.nil?
      define
    end

    # Create the tasks defined by this task lib.
    def define
      desc @description
      task @name => Array(deps) do
        FileUtilsExt.verbose(@verbose) do
          puts "Use TESTOPTS=\"--verbose\" to pass --verbose" \
            ", etc. to runners." if ARGV.include? "--verbose"
          args =
            "#{ruby_opts_string} #{run_code} " +
            "#{file_list_string} #{option_list}"
          ruby args do |ok, status|
            if !ok && status.respond_to?(:signaled?) && status.signaled?
              raise SignalException.new(status.termsig)
            elsif !ok
              status  = "Command failed with status (#{status.exitstatus})"
              details = ": [ruby #{args}]"
              message =
                if Rake.application.options.trace or @verbose
                  status + details
                else
                  status
                end

              fail message
            end
          end
        end
      end
      self
    end

    def option_list # :nodoc:
      (ENV["TESTOPTS"] ||
        ENV["TESTOPT"] ||
        ENV["TEST_OPTS"] ||
        ENV["TEST_OPT"] ||
        @options ||
        "")
    end

    def ruby_opts_string # :nodoc:
      opts = @ruby_opts.dup
      opts.unshift("-I\"#{lib_path}\"") unless @libs.empty?
      opts.unshift("-w") if @warning
      opts.join(" ")
    end

    def lib_path # :nodoc:
      @libs.join(File::PATH_SEPARATOR)
    end

    def file_list_string # :nodoc:
      file_list.map { |fn| "\"#{fn}\"" }.join(" ")
    end

    def file_list # :nodoc:
      if ENV["TEST"]
        FileList[ENV["TEST"]]
      else
        result = []
        result += @test_files.to_a if @test_files
        result += FileList[@pattern].to_a if @pattern
        result
      end
    end

    def ruby_version # :nodoc:
      RUBY_VERSION
    end

    def run_code # :nodoc:
      case @loader
      when :direct
        "-e \"ARGV.each{|f| require f}\""
      when :testrb
        "-S testrb"
      when :rake
        "#{rake_include_arg} \"#{rake_loader}\""
      end
    end

    def rake_loader # :nodoc:
      find_file("rake/rake_test_loader") or
        fail "unable to find rake test loader"
    end

    def find_file(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return file_path if File.exist? file_path
      end
      nil
    end

    def rake_include_arg # :nodoc:
      spec = Gem.loaded_specs["rake"]
      if spec.respond_to?(:default_gem?) && spec.default_gem?
        ""
      else
        "-I\"#{rake_lib_dir}\""
      end
    end

    def rake_lib_dir # :nodoc:
      find_dir("rake") or
        fail "unable to find rake lib"
    end

    def find_dir(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return path if File.exist? file_path
      end
      nil
    end

  end
end
