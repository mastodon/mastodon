# frozen_string_literal: true

class AttachmentBatch
  # Maximum amount of objects you can delete in an S3 API call. It's
  # important to remember that this does not correspond to the number
  # of records in the batch, since records can have multiple attachments
  LIMIT = 1_000

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
    batch.update_all(nullified_attributes) # rubocop:disable Rails/SkipsModelValidations
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
            attachment.directory.files.new(key: attachment.path(style)).destroy
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

    keys.each_slice(LIMIT) do |keys_slice|
      logger.debug { "Deleting #{keys_slice.size} objects" }

      bucket.delete_objects(delete: {
        objects: keys_slice.map { |key| { key: key } },
        quiet: true,
      })
    end
  end

  def bucket
    @bucket ||= records.first.public_send(@attachment_names.first).s3_bucket
  end

  def nullified_attributes
    @attachment_names.flat_map { |attachment_name| NULLABLE_ATTRIBUTES.map { |attribute| "#{attachment_name}_#{attribute}" } & klass.column_names }.index_with(nil)
  end

  def logger
    Rails.logger
  end
end
