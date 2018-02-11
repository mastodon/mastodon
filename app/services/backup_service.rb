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
    @collection = serialize(collection_presenter, ActivityPub::CollectionSerializer)
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
          dump_media_attachments!(tar)
          dump_outbox!(tar)
          dump_actor!(tar)
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

  def dump_media_attachments!(tar)
    MediaAttachment.attached.where(account: account).find_each do |m|
      file = Paperclip.io_adapters.for(m.file).read
      name = File.basename(m.file.path)

      tar.add_file_simple(File.join('media', name), 0o444, file.size) do |io|
        io.write(file)
      end
    end
  end

  def dump_outbox!(tar)
    json = Oj.dump(collection)

    tar.add_file_simple('outbox.json', 0o444, json.size) do |io|
      io.write(json)
    end
  end

  def dump_actor!(tar)
    actor = serialize(account, ActivityPub::ActorSerializer)

    actor[:icon][:url]  = 'avatar' + File.extname(actor[:icon][:url])  if actor[:icon]
    actor[:image][:url] = 'header' + File.extname(actor[:image][:url]) if actor[:image]

    if account.avatar.exists?
      file = Paperclip.io_adapters.for(account.avatar).read

      tar.add_file_simple('avatar' + File.extname(account.avatar.path), 0o444, file.size) do |io|
        io.write(file)
      end
    end

    if account.header.exists?
      file = Paperclip.io_adapters.for(account.header).read

      tar.add_file_simple('header' + File.extname(account.header.path), 0o444, file.size) do |io|
        io.write(file)
      end
    end

    json = Oj.dump(actor)

    tar.add_file_simple('actor.json', 0o444, json.size) do |io|
      io.write(json)
    end

    tar.add_file_simple('key.pem', 0o444, account.private_key.size) do |io|
      io.write(account.private_key)
    end
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_outbox_url(account),
      type: :ordered,
      size: account.statuses_count,
      items: account.statuses.with_includes
    )
  end

  def serialize(object, serializer)
    ActiveModelSerializers::SerializableResource.new(
      object,
      serializer: serializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end
end
