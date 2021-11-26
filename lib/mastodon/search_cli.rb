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

    option :concurrency, type: :numeric, default: 2, aliases: [:c], desc: 'Workload will be split between this number of threads'
    option :batch_size, type: :numeric, default: 1_000, aliases: [:b], desc: 'Number of records in each batch'
    option :only, type: :array, enum: %w(accounts tags statuses), desc: 'Only process these indices'
    desc 'deploy', 'Create or upgrade ElasticSearch indices and populate them'
    long_desc <<~LONG_DESC
      If ElasticSearch is empty, this command will create the necessary indices
      and then import data from the database into those indices.

      This command will also upgrade indices if the underlying schema has been
      changed since the last run.

      Even if creating or upgrading indices is not necessary, data from the
      database will be imported into the indices.
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

      progress = ProgressBar.create(total: nil, format: '%t%c/%u |%b%i| %e (%r docs/s)', autofinish: false)

      # First, ensure all indices are created and have the correct
      # structure, so that live data can already be written
      indices.select { |index| index.specification.changed? }.each do |index|
        progress.title = "Upgrading #{index} "
        index.purge
        index.specification.lock!
      end

      db_config = ActiveRecord::Base.configurations[Rails.env].dup
      db_config['pool'] = options[:concurrency] + 1
      ActiveRecord::Base.establish_connection(db_config)

      pool    = Concurrent::FixedThreadPool.new(options[:concurrency])
      added   = Concurrent::AtomicFixnum.new(0)
      removed = Concurrent::AtomicFixnum.new(0)

      progress.title = 'Estimating workload '

      # Estimate the amount of data that has to be imported first
      progress.total = indices.sum { |index| index.adapter.default_scope.count }

      # Now import all the actual data. Mind that unlike chewy:sync, we don't
      # fetch and compare all record IDs from the database and the index to
      # find out which to add and which to remove from the index. Because with
      # potentially millions of rows, the memory footprint of such a calculation
      # is uneconomical. So we only ever add.
      indices.each do |index|
        progress.title = "Importing #{index} "
        batch_size     = options[:batch_size]
        slice_size     = (batch_size / options[:concurrency]).ceil

        index.adapter.default_scope.reorder(nil).find_in_batches(batch_size: batch_size) do |batch|
          futures = []

          batch.each_slice(slice_size) do |records|
            futures << Concurrent::Future.execute(executor: pool) do
              begin
                if !progress.total.nil? && progress.progress + records.size > progress.total
                  # The number of items has changed between start and now,
                  # since there is no good way to predict the final count from
                  # here, just change the progress bar to an indeterminate one

                  progress.total = nil
                end

                grouped_records = nil
                bulk_body       = nil
                index_count     = 0
                delete_count    = 0

                ActiveRecord::Base.connection_pool.with_connection do
                  grouped_records = records.to_a.group_by do |record|
                    index.adapter.send(:delete_from_index?, record) ? :delete : :to_index
                  end

                  bulk_body = Chewy::Index::Import::BulkBuilder.new(index, **grouped_records).bulk_body
                end

                index_count  = grouped_records[:to_index].size  if grouped_records.key?(:to_index)
                delete_count = grouped_records[:delete].size    if grouped_records.key?(:delete)

                # The following is an optimization for statuses specifically, since
                # we want to de-index statuses that cannot be searched by anybody,
                # but can't use Chewy's delete_if logic because it doesn't use
                # crutches and our searchable_by logic depends on them
                if index == StatusesIndex
                  bulk_body.map! do |entry|
                    if entry[:to_index] && entry.dig(:to_index, :data, 'searchable_by').blank?
                      index_count  -= 1
                      delete_count += 1

                      { delete: entry[:to_index].except(:data) }
                    else
                      entry
                    end
                  end
                end

                Chewy::Index::Import::BulkRequest.new(index).perform(bulk_body)

                progress.progress += records.size

                added.increment(index_count)
                removed.increment(delete_count)

                sleep 1
              rescue => e
                progress.log pastel.red("Error importing #{index}: #{e}")
              end
            end
          end

          futures.map(&:value)
        end
      end

      progress.title = ''
      progress.stop

      say("Indexed #{added.value} records, de-indexed #{removed.value}", :green, true)
    end
  end
end
