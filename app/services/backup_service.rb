# frozen_string_literal: true

require 'rubygems/package'

class BackupService < BaseService
  include Payloadable

  attr_reader :account, :backup

  def call(backup)
    @backup  = backup
    @account = backup.user.account

    build_archive!
  end

  private

  def build_outbox_json!(file)
    skeleton = serialize(collection_presenter, ActivityPub::CollectionSerializer)
    skeleton[:orderedItems] = ['!PLACEHOLDER!']
    skeleton = Oj.dump(skeleton)
    prepend    = skeleton.gsub(/"!PLACEHOLDER!".*/, '')
    append     = skeleton.gsub(/.*"!PLACEHOLDER!"/, '')
    add_comma  = false

    file.write(prepend)

    account.statuses.with_includes.reorder(nil).find_in_batches do |statuses|
      file.write(',') if add_comma
      add_comma = true

      file.write(statuses.map do |status|
        item = serialize_payload(ActivityPub::ActivityPresenter.from_status(status), ActivityPub::ActivitySerializer)
        item.delete(:@context)

        unless item[:type] == 'Announce' || item[:object][:attachment].blank?
          item[:object][:attachment].each do |attachment|
            attachment[:url] = Addressable::URI.parse(attachment[:url]).path.gsub(/\A\/system\//, '')
          end
        end

        Oj.dump(item)
      end.join(','))

      GC.start
    end

    file.write(append)
  end

  def build_archive!
    tmp_file = Tempfile.new(%w(archive .tar.gz))

    File.open(tmp_file, 'wb') do |file|
      dump_outbox!(file)
      Zlib::GzipWriter.wrap(file) do |gz|
        Gem::Package::TarWriter.new(gz) do |tar|
          dump_media_attachments!(tar)
          dump_likes!(tar)
          dump_bookmarks!(tar)
          dump_actor!(tar)
        end
      end
    end

    archive_filename = "#{['archive', Time.now.utc.strftime('%Y%m%d%H%M%S'), SecureRandom.hex(16)].join('-')}.tar.gz"

    @backup.dump      = ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file, filename: archive_filename)
    @backup.processed = true
    @backup.save!
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def dump_media_attachments!(tar)
    MediaAttachment.attached.where(account: account).reorder(nil).find_in_batches do |media_attachments|
      media_attachments.each do |m|
        next unless m.file&.path

        download_to_tar(tar, m.file, m.file.path)
      end

      GC.start
    end
  end

  def dump_outbox!(file)
    # Placeholder for the tar header, with a compression level of 0 to ensure
    # it has a fixed size
    header_pos = file.pos
    Zlib::GzipWriter.wrap(file, 0) do |gz|
      gz.write("\0" * 512)
      gz.finish
    end

    # Output the contents of outbox.json itself
    size = 0
    Zlib::GzipWriter.wrap(file) do |gz|
      start = gz.pos
      build_outbox_json!(gz)
      size = gz.pos - start
      # Tar end padding
      remainder = (512 - (size % 512)) % 512
      gz.write("\0" * remainder)
      gz.finish
    end

    end_pos = file.pos

    # Patch the Tar header
    file.pos = header_pos
    Zlib::GzipWriter.wrap(file, 0) do |gz|
      header = Gem::Package::TarHeader.new :name => 'outbox.json', :mode => 0o444,
                                           :size => size, :prefix => '',
                                           :mtime => Gem.source_date_epoch
      gz.write(header)
      gz.finish
    end

    file.pos = end_pos
  end

  def dump_actor!(tar)
    actor = serialize(account, ActivityPub::ActorSerializer)

    actor[:icon][:url]  = "avatar#{File.extname(actor[:icon][:url])}"  if actor[:icon]
    actor[:image][:url] = "header#{File.extname(actor[:image][:url])}" if actor[:image]
    actor[:outbox]      = 'outbox.json'
    actor[:likes]       = 'likes.json'
    actor[:bookmarks]   = 'bookmarks.json'

    download_to_tar(tar, account.avatar, "avatar#{File.extname(account.avatar.path)}") if account.avatar.exists?
    download_to_tar(tar, account.header, "header#{File.extname(account.header.path)}") if account.header.exists?

    json = Oj.dump(actor)

    tar.add_file_simple('actor.json', 0o444, json.bytesize) do |io|
      io.write(json)
    end
  end

  def dump_likes!(tar)
    collection = serialize(ActivityPub::CollectionPresenter.new(id: 'likes.json', type: :ordered, size: 0, items: []), ActivityPub::CollectionSerializer)

    Status.reorder(nil).joins(:favourites).includes(:account).merge(account.favourites).find_in_batches do |statuses|
      statuses.each do |status|
        collection[:totalItems] += 1
        collection[:orderedItems] << ActivityPub::TagManager.instance.uri_for(status)
      end

      GC.start
    end

    json = Oj.dump(collection)

    tar.add_file_simple('likes.json', 0o444, json.bytesize) do |io|
      io.write(json)
    end
  end

  def dump_bookmarks!(tar)
    collection = serialize(ActivityPub::CollectionPresenter.new(id: 'bookmarks.json', type: :ordered, size: 0, items: []), ActivityPub::CollectionSerializer)

    Status.reorder(nil).joins(:bookmarks).includes(:account).merge(account.bookmarks).find_in_batches do |statuses|
      statuses.each do |status|
        collection[:totalItems] += 1
        collection[:orderedItems] << ActivityPub::TagManager.instance.uri_for(status)
      end

      GC.start
    end

    json = Oj.dump(collection)

    tar.add_file_simple('bookmarks.json', 0o444, json.bytesize) do |io|
      io.write(json)
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

  CHUNK_SIZE = 1.megabyte

  def download_to_tar(tar, attachment, filename)
    adapter = Paperclip.io_adapters.for(attachment)

    tar.add_file_simple(filename, 0o444, adapter.size) do |io|
      while (buffer = adapter.read(CHUNK_SIZE))
        io.write(buffer)
      end
    end
  rescue Errno::ENOENT, Seahorse::Client::NetworkingError => e
    Rails.logger.warn "Could not backup file #{filename}: #{e}"
  end
end
