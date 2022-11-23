# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class SearchCLI < Thor
    include CLIHelper

    # Indices are sorted by amount of data to be expected in each, so that
    # smaller indices can go online sooner
    INDICES = [
      AccountsIndex,
      TagsIndex,
      StatusesIndex,
    ].freeze

    option :concurrency, type: :numeric, default: 5, aliases: [:c], desc: 'Workload will be split between this number of threads'
    option :batch_size, type: :numeric, default: 100, aliases: [:b], desc: 'Number of records in each batch'
    option :only, type: :array, enum: %w(accounts tags statuses), desc: 'Only process these indices'
    option :import, type: :boolean, default: true, desc: 'Import data from the database to the index'
    option :clean, type: :boolean, default: true, desc: 'Remove outdated documents from the index'
    desc 'deploy', 'Create or upgrade Elasticsearch indices and populate them'
    long_desc <<~LONG_DESC
      If Elasticsearch is empty, this command will create the necessary indices
      and then import data from the database into those indices.

      This command will also upgrade indices if the underlying schema has been
      changed since the last run. Index upgrades erase index data.

      Even if creating or upgrading indices is not necessary, data from the
      database will be imported into the indices, unless overridden with --no-import.
    LONG_DESC
    def deploy
      if options[:concurrency] < 1
        say('Cannot run with this concurrency setting, must be at least 1', :red)
        exit(1)
      end

      if options[:batch_size] < 1
        say('Cannot run with this batch_size setting, must be at least 1', :red)
        exit(1)
      end

      indices = begin
        if options[:only]
          options[:only].map { |str| "#{str.camelize}Index".constantize }
        else
          INDICES
        end
      end

      pool      = Concurrent::FixedThreadPool.new(options[:concurrency], max_queue: options[:concurrency] * 10)
      importers = indices.index_with { |index| "Importer::#{index.name}Importer".constantize.new(batch_size: options[:batch_size], executor: pool) }
      progress  = ProgressBar.create(total: nil, format: '%t%c/%u |%b%i| %e (%r docs/s)', autofinish: false)

      # First, ensure all indices are created and have the correct
      # structure, so that live data can already be written
      indices.select { |index| index.specification.changed? }.each do |index|
        progress.title = "Upgrading #{index} "
        index.purge
        index.specification.lock!
      end

      progress.title = 'Estimating workload '
      progress.total = indices.sum { |index| importers[index].estimate! }

      reset_connection_pools!

      added   = 0
      removed = 0

      indices.each do |index|
        importer = importers[index]
        importer.optimize_for_import!

        importer.on_progress do |(indexed, deleted)|
          progress.total = nil if progress.progress + indexed + deleted > progress.total
          progress.progress += indexed + deleted
          added   += indexed
          removed += deleted
        end

        importer.on_failure do |reason|
          progress.log(pastel.red("Error while importing #{index}: #{reason}"))
        end

        if options[:import]
          progress.title = "Importing #{index} "
          importer.import!
        end

        if options[:clean]
          progress.title = "Cleaning #{index} "
          importer.clean_up!
        end
      ensure
        importer.optimize_for_search!
      end

      progress.title = 'Done! '
      progress.finish

      say("Indexed #{added} records, de-indexed #{removed}", :green, true)
    end
  end
end
