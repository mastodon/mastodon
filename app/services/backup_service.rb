# frozen_string_literal: true

require 'zip'

class BackupService < BaseService
  include Payloadable
  include ContextHelper

  CHUNK_SIZE = 1.megabyte

  attr_reader :account, :backup

  def call(backup)
    @backup  = backup
    @account = backup.user.account

    build_archive!
  end

  private

  def build_outbox_json!(file)
    skeleton = serialize(collection_presenter, ActivityPub::CollectionSerializer)
    skeleton[:@context] = full_context
    skeleton[:orderedItems] = ['!PLACEHOLDER!']
    skeleton = Oj.dump(skeleton)
    prepend, append = skeleton.split('"!PLACEHOLDER!"')
    add_comma = false

    file.write(prepend)

    account.statuses.with_includes.reorder(nil).find_in_batches do |statuses|
      file.write(',') if add_comma
      add_comma = true

      file.write(statuses.map do |status|
        serializer = status.reblog? ? ActivityPub::AnnounceNoteSerializer : ActivityPub::CreateNoteSerializer
        item = serialize_payload(status, serializer)
        item.delete(:@context)

        unless item[:type] == 'Announce' || item[:object][:attachment].blank?
          item[:object][:attachment].each do |attachment|
            attachment[:url] = Addressable::URI.parse(attachment[:url]).path.delete_prefix('/system/')
          end
        end

        Oj.dump(item)
      end.join(','))

      GC.start
    end

    file.write(append)
  end

  def build_archive!
    tmp_file = Tempfile.new(%w(archive .zip))

    Zip::File.open(tmp_file, create: true) do |zipfile|
      dump_outbox!(zipfile)
      dump_media_attachments!(zipfile)
      dump_likes!(zipfile)
      dump_bookmarks!(zipfile)
      dump_actor!(zipfile)
    end

    archive_filename = "#{['archive', Time.current.to_fs(:number), SecureRandom.hex(16)].join('-')}.zip"

    @backup.dump      = ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file, filename: archive_filename)
    @backup.processed = true
    @backup.save!
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def dump_media_attachments!(zipfile)
    MediaAttachment.attached.where(account: account).find_in_batches do |media_attachments|
      media_attachments.each do |m|
        path = m.file&.path
        next unless path

        path = path.gsub(%r{\A.*/system/}, '')
        path = path.gsub(%r{\A/+}, '')
        download_to_zip(zipfile, m.file, path)
      end

      GC.start
    end
  end

  def dump_outbox!(zipfile)
    zipfile.get_output_stream('outbox.json') do |io|
      build_outbox_json!(io)
    end
  end

  def dump_actor!(zipfile)
    actor = serialize(account, ActivityPub::ActorSerializer)

    actor[:icon][:url]  = "avatar#{File.extname(actor[:icon][:url])}"  if actor[:icon]
    actor[:image][:url] = "header#{File.extname(actor[:image][:url])}" if actor[:image]
    actor[:outbox]      = 'outbox.json'
    actor[:likes]       = 'likes.json'
    actor[:bookmarks]   = 'bookmarks.json'

    download_to_zip(zipfile, account.avatar, "avatar#{File.extname(account.avatar.path)}") if account.avatar.exists?
    download_to_zip(zipfile, account.header, "header#{File.extname(account.header.path)}") if account.header.exists?

    json = Oj.dump(actor)

    zipfile.get_output_stream('actor.json') do |io|
      io.write(json)
    end
  end

  def dump_likes!(zipfile)
    skeleton = serialize(ActivityPub::CollectionPresenter.new(id: 'likes.json', type: :ordered, size: 0, items: []), ActivityPub::CollectionSerializer)
    skeleton.delete(:totalItems)
    skeleton[:orderedItems] = ['!PLACEHOLDER!']
    skeleton = Oj.dump(skeleton)
    prepend, append = skeleton.split('"!PLACEHOLDER!"')

    zipfile.get_output_stream('likes.json') do |io|
      io.write(prepend)

      add_comma = false

      Status.reorder(nil).joins(:favourites).includes(:account).merge(account.favourites).find_in_batches do |statuses|
        io.write(',') if add_comma
        add_comma = true

        io.write(statuses.map do |status|
          Oj.dump(ActivityPub::TagManager.instance.uri_for(status))
        end.join(','))

        GC.start
      end

      io.write(append)
    end
  end

  def dump_bookmarks!(zipfile)
    skeleton = serialize(ActivityPub::CollectionPresenter.new(id: 'bookmarks.json', type: :ordered, size: 0, items: []), ActivityPub::CollectionSerializer)
    skeleton.delete(:totalItems)
    skeleton[:orderedItems] = ['!PLACEHOLDER!']
    skeleton = Oj.dump(skeleton)
    prepend, append = skeleton.split('"!PLACEHOLDER!"')

    zipfile.get_output_stream('bookmarks.json') do |io|
      io.write(prepend)

      add_comma = false
      Status.reorder(nil).joins(:bookmarks).includes(:account).merge(account.bookmarks).find_in_batches do |statuses|
        io.write(',') if add_comma
        add_comma = true

        io.write(statuses.map do |status|
          Oj.dump(ActivityPub::TagManager.instance.uri_for(status))
        end.join(','))

        GC.start
      end

      io.write(append)
    end
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: 'outbox.json',
      type: :ordered,
      size: account.statuses_count,
      items: []
    )
  end

  def serialize(object, serializer)
    ActiveModelSerializers::SerializableResource.new(
      object,
      serializer: serializer,
      adapter: ActivityPub::Adapter
    ).as_json
  end

  def download_to_zip(zipfile, attachment, filename)
    adapter = Paperclip.io_adapters.for(attachment)

    zipfile.get_output_stream(filename) do |io|
      while (buffer = adapter.read(CHUNK_SIZE))
        io.write(buffer)
      end
    end
  rescue Errno::ENOENT, Seahorse::Client::NetworkingError => e
    Rails.logger.warn "Could not backup file #{filename}: #{e}"
  end
end
