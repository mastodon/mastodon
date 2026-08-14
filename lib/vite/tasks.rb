# frozen_string_literal: true

module Vite
  class Tasks
    attr_reader :config, :logger

    def initialize(config:)
      @config = config
      # We want tasks to always log out to STDOUT
      @logger = ActiveSupport::TaggedLogging.new(
        ActiveSupport::Logger.new($stdout)
      ).tagged('vite')
    end

    # Intended to run within assets:precompile task
    def precompile
      Vite::Builder.new(config:, logger:).build!
    end

    # Intended to run within assets:clobber task
    def clobber
      [config.out_dir, config.cache_dir].each do |path|
        dir = Rails.root.join(path)
        if dir.exist?
          logger.info { "Deleting directory '#{dir}'" }
          dir.rmtree
        else
          logger.info { "Directory '#{dir}' doesn't exist, nothing to delete" }
        end
      end
    end
  end
end
