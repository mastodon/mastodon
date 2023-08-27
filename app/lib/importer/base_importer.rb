# frozen_string_literal: true

class Importer::BaseImporter
  # @param [Integer] batch_size
  # @param [Concurrent::ThreadPoolExecutor] executor
  def initialize(batch_size:, executor:)
    @batch_size = batch_size
    @executor   = executor
    @wait_for   = Concurrent::Set.new
  end

  # Callback to run when a concurrent work unit completes
  # @param [Proc]
  def on_progress(&block)
    @on_progress = block
  end

  # Callback to run when a concurrent work unit fails
  # @param [Proc]
  def on_failure(&block)
    @on_failure = block
  end

  # Reduce resource usage during and improve speed of indexing
  def optimize_for_import!
    Chewy.client.indices.put_settings index: index.index_name, body: { index: { refresh_interval: -1 } }
  end

  # Restore original index settings
  def optimize_for_search!
    Chewy.client.indices.put_settings index: index.index_name, body: { index: { refresh_interval: index.settings_hash[:settings][:index][:refresh_interval] } }
  end

  # Estimate the amount of documents that would be indexed. Not exact!
  # @returns [Integer]
  def estimate!
    ActiveRecord::Base.connection_pool.with_connection { |connection| connection.select_one("SELECT reltuples AS estimate FROM pg_class WHERE relname = '#{index.adapter.target.table_name}'")['estimate'].to_i }
  end

  # Import data from the database into the index
  def import!
    raise NotImplementedError
  end

  # Remove documents from the index that no longer exist in the database
  def clean_up!
    index.scroll_batches do |documents|
      primary_key = index.adapter.target.primary_key
      raise ActiveRecord::UnknownPrimaryKey, index.adapter.target if primary_key.nil?

      ids           = documents.pluck('_id')
      existence_map = index.adapter.target.where(primary_key => ids).pluck(primary_key).each_with_object({}) { |id, map| map[id.to_s] = true }
      tmp           = ids.reject { |id| existence_map[id] }

      next if tmp.empty?

      in_work_unit(tmp) do |deleted_ids|
        bulk = Chewy::Index::Import::BulkBuilder.new(index, delete: deleted_ids).bulk_body

        Chewy::Index::Import::BulkRequest.new(index).perform(bulk)

        [0, bulk.size]
      end
    end

    wait!
  end

  protected

  def in_work_unit(...)
    work_unit = Concurrent::Promises.future_on(@executor, ...)

    work_unit.on_fulfillment!(&@on_progress)
    work_unit.on_rejection!(&@on_failure)
    work_unit.on_resolution! { @wait_for.delete(work_unit) }

    @wait_for << work_unit
  rescue Concurrent::RejectedExecutionError
    sleep(0.1) && retry # Backpressure
  end

  def wait!
    Concurrent::Promises.zip(*@wait_for).wait
  end

  def index
    raise NotImplementedError
  end
end
