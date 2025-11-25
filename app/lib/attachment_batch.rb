# frozen_string_literal: true

class AttachmentBatch
  # Maximum amount of objects you can delete in an S3 API call. It's
  # important to remember that this does not correspond to the number
  # of records in the batch, since records can have multiple attachments
  LIMIT = ENV.fetch('S3_BATCH_DELETE_LIMIT', 1000).to_i
  MAX_RETRY = ENV.fetch('S3_BATCH_DELETE_RETRY', 3).to_i

  # Attributes generated and maintained by Paperclip (not all of them
  # are always used on every class, however)
  NULLABLE_ATTRIBUTES = %w(
    file_name
    content_type
    file_size
    fingerprint
    created_at
    updated_at
  ).freeze

  # Styles that are always present even when not explicitly defined
  BASE_STYLES = %i(original).freeze

  attr_reader :klass, :records, :storage_mode

  def initialize(klass, records)
    @klass            = klass
    @records          = records
    @storage_mode     = Paperclip::Attachment.default_options[:storage]
    @attachment_names = klass.attachment_definitions.keys
  end

  def delete
    remove_files
    batch.delete_all
  end

  def clear
    remove_files
    batch.update_all(nullified_attributes)
  end

  private

  def batch
    klass.where(id: records.map(&:id))
  end

  def remove_files
    keys = []

    logger.debug { "Preparing to delete attachments for #{records.size} records" }

    records.each do |record|
      @attachment_names.each do |attachment_name|
        attachment = record.public_send(attachment_name)
        styles     = BASE_STYLES | attachment.styles.keys

        next if attachment.blank?

        styles.each do |style|
          case @storage_mode
          when :s3
            logger.debug { "Adding #{attachment.path(style)} to batch for deletion" }
            keys << attachment.style_name_as_path(style)
          when :filesystem
            logger.debug { "Deleting #{attachment.path(style)}" }
            path = attachment.path(style)
            FileUtils.remove_file(path, true)

            begin
              FileUtils.rmdir(File.dirname(path), parents: true)
            rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR, Errno::EACCES
              # Ignore failure to delete a directory, with the same ignored errors
              # as Paperclip
            end
          when :fog
            logger.debug { "Deleting #{attachment.path(style)}" }

            retries = 0
            begin
              attachment.send(:directory).files.new(key: attachment.path(style)).destroy
            rescue Fog::OpenStack::Storage::NotFound
              logger.debug "Will ignore because file is not found #{attachment.path(style)}"
            rescue => e
              retries += 1

              if retries < MAX_RETRY
                logger.debug "Retry #{retries}/#{MAX_RETRY} after #{e.message}"
                sleep 2**retries
                retry
              else
                logger.error "Batch deletion from fog failed after #{e.message}"
                raise e
              end
            end
          when :azure
            logger.debug { "Deleting #{attachment.path(style)}" }
            attachment.destroy
          end
        end
      end
    end

    return unless storage_mode == :s3

    # We can batch deletes over S3, but there is a limit of how many
    # objects can be processed at once, so we have to potentially
    # separate them into multiple calls.

    retries = 0
    keys.each_slice(LIMIT) do |keys_slice|
      logger.debug { "Deleting #{keys_slice.size} objects" }

      with_overridden_timeout(bucket.client, 120) do
        bucket.delete_objects(delete: {
          objects: keys_slice.map { |key| { key: key } },
          quiet: true,
        })
      end
    rescue => e
      retries += 1

      if retries < MAX_RETRY
        logger.debug "Retry #{retries}/#{MAX_RETRY} after #{e.message}"
        sleep 2**retries
        retry
      else
        logger.error "Batch deletion from S3 failed after #{e.message}"
        raise e
      end
    end
  end

  def bucket
    @bucket ||= records.first.public_send(@attachment_names.first).s3_bucket
  end

  # Currently, the aws-sdk-s3 gem does not offer a way to cleanly override the timeout
  # per-request. So we change the client's config instead. As this client will likely
  # be re-used for other jobs, restore its original configuration in an `ensure` block.
  def with_overridden_timeout(s3_client, longer_read_timeout)
    original_timeout = s3_client.config.http_read_timeout
    s3_client.config.http_read_timeout = [original_timeout, longer_read_timeout].max

    begin
      yield
    ensure
      s3_client.config.http_read_timeout = original_timeout
    end
  end

  def nullified_attributes
    @attachment_names.flat_map { |attachment_name| NULLABLE_ATTRIBUTES.map { |attribute| "#{attachment_name}_#{attribute}" } & klass.column_names }.index_with(nil)
  end

  def logger
    Rails.logger
  end
end
