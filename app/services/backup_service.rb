# frozen_string_literal: true

require 'rubygems/package'

class BackupService < BaseService
  attr_reader :account, :backup, :collection

  def call(backup)
    @backup  = backup
    @account = backup.user.account

    build_json!
    process!
    build_archive!
  end

  private

  def build_json!
    @collection = ActiveModelSerializers::SerializableResource.new(collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter).as_json
  end

  def process!
    @collection[:orderedItems].each do |item|
      next if item[:type] == 'Announce' || item[:object][:attachment].blank?

      item[:object][:attachment].each do |attachment|
        attachment[:url] = File.join('media', File.basename(attachment[:url]))
      end
    end
  end

  def build_archive!
    tmp_file = Tempfile.new(%w(archive .tar.gz))

    File.open(tmp_file, 'wb') do |file|
      Zlib::GzipWriter.wrap(file) do |gz|
        Gem::Package::TarWriter.new(gz) do |tar|
          MediaAttachment.attached.where(account: account).find_each do |m|
            file = Paperclip.io_adapters.for(m.file).read
            name = File.basename(m.file.path)

            tar.add_file_simple(File.join('media', name), 0o444, file.size) do |io|
              io.write(file)
            end
          end

          json = Oj.dump(collection)

          tar.add_file_simple('collection.json', 0o444, json.size) do |io|
            io.write(json)
          end
        end
      end
    end

    @backup.dump      = tmp_file
    @backup.processed = true
    @backup.save!
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_outbox_url(account),
      type: :ordered,
      size: account.statuses_count,
      items: account.statuses.with_includes
    )
  end
end
