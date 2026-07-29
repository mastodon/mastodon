# frozen_string_literal: true

# Integration library between Mastodon backend and Vite
module Vite
  class Builder
    attr_reader :config, :logger

    def initialize(config:, logger:)
      @config = config
      @logger = logger
    end

    def build
      logger.info { "Build: Building assets with vite with command: '#{config.build_command}'" }
      Open3.popen3(config.build_command) do |_stdin, stdout, stderr, _wait_thread|
        read_pipe(stdout) do |line|
          logger.info { line }
        end
        read_pipe(stderr) do |line|
          logger.warn { line }
        end
      end
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
