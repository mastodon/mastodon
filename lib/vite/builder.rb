# frozen_string_literal: true

module Vite
  # Execute the configured build command and log its output
  # @see Vite::Config#build_command
  class Builder
    class BuildError < StandardError
      def initialize(command, exit_status)
        super("Vite build command '#{command}' failed with status: #{exit_status}")
      end
    end

    attr_reader :config, :logger

    def initialize(config:, logger:)
      @config = config
      @logger = logger
    end

    def build
      logger.info { "Build: Building assets with vite with command: '#{config.build_command}'" }
      Open3.popen3(config.build_command) do |_stdin, stdout, stderr, wait_thread|
        read_pipe(stdout) do |line|
          logger.info { line.strip }
        end
        read_pipe(stderr) do |line|
          logger.error { line.strip }
        end

        wait_thread.value
      end
    end

    def build!
      status = build

      raise(BuildError.new(config.build_command, status.exitstatus)) unless status.success?
    end

    private

    def read_pipe(io)
      while (line = io.gets)
        next if line.blank?

        yield line
      end
    end
  end
end
