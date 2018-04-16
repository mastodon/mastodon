# frozen_string_literal: true

require 'thor'

module SidekiqUniqueJobs
  class Cli < Thor
    # def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
    #   @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    # end

    def self.banner(command, _namespace = nil, _subcommand = false)
      "jobs #{@package_name} #{command.usage}"
    end

    desc 'keys PATTERN', 'list all unique keys and their expiry time'
    option :count, aliases: :c, type: :numeric, default: 1000, desc: 'The max number of keys to return'
    def keys(pattern)
      keys = Util.keys(pattern, options[:count])
      say "Found #{keys.size} keys matching '#{pattern}':"
      print_in_columns(keys.sort) if keys.any?
    end

    desc 'del PATTERN', 'deletes unique keys from redis by pattern'
    option :dry_run, aliases: :d, type: :boolean, desc: 'set to false to perform deletion'
    option :count, aliases: :c, type: :numeric, default: 1000, desc: 'The max number of keys to return'
    def del(pattern)
      deleted_count = Util.del(pattern, options[:count], options[:dry_run])
      say "Deleted #{deleted_count} keys matching '#{pattern}'"
    end

    desc 'expire', 'removes all expired unique keys from the hash in redis'
    def expire
      expired = Util.expire
      say "Removed #{expired.values.size} left overs from redis."
      print_in_columns(expired.values)
    end

    desc 'console', 'drop into a console with easy access to helper methods'
    def console
      say "Use `keys '*', 1000 to display the first 1000 unique keys matching '*'"
      say "Use `del '*', 1000, true (default) to see how many keys would be deleted for the pattern '*'"
      say "Use `del '*', 1000, false to delete the first 1000 keys matching '*'"
      Object.include SidekiqUniqueJobs::Util
      console_class.start
    end

    no_commands do
      def logger
        SidekiqUniqueJobs.logger
      end

      def console_class
        require 'pry'
        Pry
      rescue LoadError
        require 'irb'
        IRB
      end
    end
  end
end
