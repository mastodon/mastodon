# frozen_string_literal: true
require 'time'
require 'logger'
require 'fcntl'

module Sidekiq
  module Logging

    class Pretty < Logger::Formatter
      SPACE = " "

      # Provide a call() method that returns the formatted message.
      def call(severity, time, program_name, message)
        "#{time.utc.iso8601(3)} #{::Process.pid} TID-#{Sidekiq::Logging.tid}#{context} #{severity}: #{message}\n"
      end

      def context
        c = Thread.current[:sidekiq_context]
        " #{c.join(SPACE)}" if c && c.any?
      end
    end

    class WithoutTimestamp < Pretty
      def call(severity, time, program_name, message)
        "#{::Process.pid} TID-#{Sidekiq::Logging.tid}#{context} #{severity}: #{message}\n"
      end
    end

    def self.tid
      Thread.current['sidekiq_tid'] ||= (Thread.current.object_id ^ ::Process.pid).to_s(36)
    end

    def self.job_hash_context(job_hash)
      # If we're using a wrapper class, like ActiveJob, use the "wrapped"
      # attribute to expose the underlying thing.
      klass = job_hash['wrapped'] || job_hash["class"]
      bid = job_hash['bid']
      "#{klass} JID-#{job_hash['jid']}#{" BID-#{bid}" if bid}"
    end

    def self.with_job_hash_context(job_hash, &block)
      with_context(job_hash_context(job_hash), &block)
    end

    def self.with_context(msg)
      Thread.current[:sidekiq_context] ||= []
      Thread.current[:sidekiq_context] << msg
      yield
    ensure
      Thread.current[:sidekiq_context].pop
    end

    def self.initialize_logger(log_target = STDOUT)
      oldlogger = defined?(@logger) ? @logger : nil
      @logger = Logger.new(log_target)
      @logger.level = Logger::INFO
      @logger.formatter = ENV['DYNO'] ? WithoutTimestamp.new : Pretty.new
      oldlogger.close if oldlogger && !$TESTING # don't want to close testing's STDOUT logging
      @logger
    end

    def self.logger
      defined?(@logger) ? @logger : initialize_logger
    end

    def self.logger=(log)
      @logger = (log ? log : Logger.new(File::NULL))
    end

    # This reopens ALL logfiles in the process that have been rotated
    # using logrotate(8) (without copytruncate) or similar tools.
    # A +File+ object is considered for reopening if it is:
    #   1) opened with the O_APPEND and O_WRONLY flags
    #   2) the current open file handle does not match its original open path
    #   3) unbuffered (as far as userspace buffering goes, not O_SYNC)
    # Returns the number of files reopened
    def self.reopen_logs
      to_reopen = []
      append_flags = File::WRONLY | File::APPEND

      ObjectSpace.each_object(File) do |fp|
        begin
          if !fp.closed? && fp.stat.file? && fp.sync && (fp.fcntl(Fcntl::F_GETFL) & append_flags) == append_flags
            to_reopen << fp
          end
        rescue IOError, Errno::EBADF
        end
      end

      nr = 0
      to_reopen.each do |fp|
        orig_st = begin
          fp.stat
        rescue IOError, Errno::EBADF
          next
        end

        begin
          b = File.stat(fp.path)
          next if orig_st.ino == b.ino && orig_st.dev == b.dev
        rescue Errno::ENOENT
        end

        begin
          File.open(fp.path, 'a') { |tmpfp| fp.reopen(tmpfp) }
          fp.sync = true
          nr += 1
        rescue IOError, Errno::EBADF
          # not much we can do...
        end
      end
      nr
    rescue RuntimeError => ex
      # RuntimeError: ObjectSpace is disabled; each_object will only work with Class, pass -X+O to enable
      puts "Unable to reopen logs: #{ex.message}"
    end

    def logger
      Sidekiq::Logging.logger
    end
  end
end
