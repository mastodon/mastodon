# frozen_string_literal: true
require "rake/file_utils"

module Rake
  #
  # FileUtilsExt provides a custom version of the FileUtils methods
  # that respond to the <tt>verbose</tt> and <tt>nowrite</tt>
  # commands.
  #
  module FileUtilsExt
    include FileUtils

    class << self
      attr_accessor :verbose_flag, :nowrite_flag
    end

    DEFAULT = Object.new

    FileUtilsExt.verbose_flag = DEFAULT
    FileUtilsExt.nowrite_flag = false

    FileUtils.commands.each do |name|
      opts = FileUtils.options_of name
      default_options = []
      if opts.include?("verbose")
        default_options << ":verbose => FileUtilsExt.verbose_flag"
      end
      if opts.include?("noop")
        default_options << ":noop => FileUtilsExt.nowrite_flag"
      end

      next if default_options.empty?
      module_eval(<<-EOS, __FILE__, __LINE__ + 1)
      def #{name}( *args, &block )
        super(
          *rake_merge_option(args,
            #{default_options.join(', ')}
            ), &block)
      end
      EOS
    end

    # Get/set the verbose flag controlling output from the FileUtils
    # utilities.  If verbose is true, then the utility method is
    # echoed to standard output.
    #
    # Examples:
    #    verbose              # return the current value of the
    #                         # verbose flag
    #    verbose(v)           # set the verbose flag to _v_.
    #    verbose(v) { code }  # Execute code with the verbose flag set
    #                         # temporarily to _v_.  Return to the
    #                         # original value when code is done.
    def verbose(value=nil)
      oldvalue = FileUtilsExt.verbose_flag
      FileUtilsExt.verbose_flag = value unless value.nil?
      if block_given?
        begin
          yield
        ensure
          FileUtilsExt.verbose_flag = oldvalue
        end
      end
      FileUtilsExt.verbose_flag
    end

    # Get/set the nowrite flag controlling output from the FileUtils
    # utilities.  If verbose is true, then the utility method is
    # echoed to standard output.
    #
    # Examples:
    #    nowrite              # return the current value of the
    #                         # nowrite flag
    #    nowrite(v)           # set the nowrite flag to _v_.
    #    nowrite(v) { code }  # Execute code with the nowrite flag set
    #                         # temporarily to _v_. Return to the
    #                         # original value when code is done.
    def nowrite(value=nil)
      oldvalue = FileUtilsExt.nowrite_flag
      FileUtilsExt.nowrite_flag = value unless value.nil?
      if block_given?
        begin
          yield
        ensure
          FileUtilsExt.nowrite_flag = oldvalue
        end
      end
      oldvalue
    end

    # Use this function to prevent potentially destructive ruby code
    # from running when the :nowrite flag is set.
    #
    # Example:
    #
    #   when_writing("Building Project") do
    #     project.build
    #   end
    #
    # The following code will build the project under normal
    # conditions. If the nowrite(true) flag is set, then the example
    # will print:
    #
    #      DRYRUN: Building Project
    #
    # instead of actually building the project.
    #
    def when_writing(msg=nil)
      if FileUtilsExt.nowrite_flag
        $stderr.puts "DRYRUN: #{msg}" if msg
      else
        yield
      end
    end

    # Merge the given options with the default values.
    def rake_merge_option(args, defaults)
      if Hash === args.last
        defaults.update(args.last)
        args.pop
      end
      args.push defaults
      args
    end

    # Send the message to the default rake output (which is $stderr).
    def rake_output_message(message)
      $stderr.puts(message)
    end

    # Check that the options do not contain options not listed in
    # +optdecl+.  An ArgumentError exception is thrown if non-declared
    # options are found.
    def rake_check_options(options, *optdecl)
      h = options.dup
      optdecl.each do |name|
        h.delete name
      end
      raise ArgumentError, "no such option: #{h.keys.join(' ')}" unless
        h.empty?
    end

    extend self
  end
end
