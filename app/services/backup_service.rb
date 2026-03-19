# frozen_string_literal: true

require 'zip'

class BackupService < BaseService
  include Payloadable
  include ContextHelper

  CHUNK_SIZE = 1.megabyte
  PLACEHOLDER = '!PLACEHOLDER!'

  STREAM_ACTOR = 'actor.json'
  STREAM_BOOKMARKS = 'bookmarks.json'
  STREAM_LIKES = 'likes.json'
  STREAM_OUTBOX = 'outbox.json'

  attr_reader :account, :backup

  def call(backup)
    @backup  = backup
    @account = backup.user.account

    build_archive!
  end

  private

  def build_outbox_json!(file)
    skeleton = serialize(collection_presenter(STREAM_OUTBOX, size: account.statuses.count), ActivityPub::CollectionSerializer)
    skeleton[:@context] = full_context
    skeleton[:orderedItems] = [PLACEHOLDER]
    skeleton = skeleton.to_json
    prepend, append = skeleton.split(PLACEHOLDER.to_json)

    file.write(prepend)

    account.statuses.with_includes.reorder(nil).find_in_batches.with_index do |statuses, batch|
      file.write(',') unless batch.zero?

      file.write(statuses.map do |status|
        serializer = status.reblog? ? ActivityPub::AnnounceNoteSerializer : ActivityPub::CreateNoteSerializer
        item = serialize_payload(status, serializer, allow_local_only: true)
        item.delete(:@context)

        unless item[:type] == 'Announce' || item[:object][:attachment].blank?
          item[:object][:attachment].each do |attachment|
            attachment[:url] = Addressable::URI.parse(attachment[:url]).path.delete_prefix('/system/')
          end
        end

        item.to_json
      end.join(','))

      GC.start
    end

    file.write(append)
  end

  def build_archive!
    tmp_file = Tempfile.new(%w(archive .zip))

    build_zip_file(tmp_file)

    @backup.dump = ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file, filename: archive_filename)
    @backup.processed = true
    @backup.save!
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def build_zip_file(file)
    Zip::File.open(file, create: true) do |zip|
      dump_outbox!(zip)
      dump_media_attachments!(zip)
      dump_likes!(zip)
      dump_bookmarks!(zip)
      dump_actor!(zip)
    end
  end

  def archive_filename
    "#{archive_id}.zip"
  end

  def archive_id
    [:archive, Time.current.to_fs(:number), SecureRandom.hex(16)].join('-')
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
    zipfile.get_output_stream(STREAM_OUTBOX) do |io|
      build_outbox_json!(io)
    end
  end

  def dump_actor!(zipfile)
    actor = serialize(account, ActivityPub::ActorSerializer)

    actor[:icon][:url]  = "avatar#{File.extname(actor[:icon][:url])}"  if actor[:icon]
    actor[:image][:url] = "header#{File.extname(actor[:image][:url])}" if actor[:image]
    actor[:outbox]      = STREAM_OUTBOX
    actor[:likes]       = STREAM_LIKES
    actor[:bookmarks]   = STREAM_BOOKMARKS

    download_to_zip(zipfile, account.avatar, "avatar#{File.extname(account.avatar.path)}") if account.avatar.exists?
    download_to_zip(zipfile, account.header, "header#{File.extname(account.header.path)}") if account.header.exists?

    zipfile.get_output_stream(STREAM_ACTOR) do |io|
      io.write(actor.to_json)
    end
  end

  def dump_likes!(zipfile)
    skeleton = serialize(collection_presenter(STREAM_LIKES), ActivityPub::CollectionSerializer)

    skeleton.delete(:totalItems)
    skeleton[:orderedItems] = [PLACEHOLDER]
    skeleton = skeleton.to_json
    prepend, append = skeleton.split(PLACEHOLDER.to_json)

    zipfile.get_output_stream(STREAM_LIKES) do |io|
      io.write(prepend)

      favourite_statuses.find_in_batches.with_index do |statuses, batch|
        io.write(',') unless batch.zero?

        io.write(statuses.map do |status|
          ActivityPub::TagManager.instance.uri_for(status).to_json
        end.join(','))

        GC.start
      end

      io.write(append)
    end
  end

  def favourite_statuses
    Status.reorder(nil).joins(:favourites).includes(:account).merge(account.favourites)
  end

  def dump_bookmarks!(zipfile)
    skeleton = serialize(collection_presenter(STREAM_BOOKMARKS), ActivityPub::CollectionSerializer)
    skeleton.delete(:totalItems)
    skeleton[:orderedItems] = [PLACEHOLDER]
    skeleton = skeleton.to_json
    prepend, append = skeleton.split(PLACEHOLDER.to_json)

    zipfile.get_output_stream(STREAM_BOOKMARKS) do |io|
      io.write(prepend)

      bookmark_statuses.find_in_batches.with_index do |statuses, batch|
        io.write(',') unless batch.zero?

        io.write(statuses.map do |status|
          ActivityPub::TagManager.instance.uri_for(status).to_json
        end.join(','))

        GC.start
      end

      io.write(append)
    end
  end

  def bookmark_statuses
    Status.reorder(nil).joins(:bookmarks).includes(:account).merge(account.bookmarks)
  end

  def collection_presenter(id, size: 0)
    ActivityPub::CollectionPresenter.new(
      id:,
      items: [],
      size:,
      type: :ordered
    )
  end

  def serialize(object, serializer)
    ActiveModelSerializers::SerializableResource.new(
      object,
      serializer: serializer,
      adapter: ActivityPub::Adapter,
      allow_local_only: true
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
