# frozen_string_literal: true

# == Schema Information
#
# Table name: media_attachments
#
#  id                          :bigint(8)        not null, primary key
#  status_id                   :bigint(8)
#  file_file_name              :string
#  file_content_type           :string
#  file_file_size              :integer
#  file_updated_at             :datetime
#  remote_url                  :string           default(""), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  shortcode                   :string
#  type                        :integer          default("image"), not null
#  file_meta                   :json
#  account_id                  :bigint(8)
#  description                 :text
#  scheduled_status_id         :bigint(8)
#  blurhash                    :string
#  processing                  :integer
#  file_storage_schema_version :integer
#  thumbnail_file_name         :string
#  thumbnail_content_type      :string
#  thumbnail_file_size         :integer
#  thumbnail_updated_at        :datetime
#  thumbnail_remote_url        :string
#

class MediaAttachment < ApplicationRecord
  self.inheritance_column = nil

  include Attachmentable

  enum :type, { image: 0, gifv: 1, video: 2, unknown: 3, audio: 4 }
  enum :processing, { queued: 0, in_progress: 1, complete: 2, failed: 3 }, prefix: true

  MAX_DESCRIPTION_LENGTH = 1_500

  IMAGE_LIMIT = (ENV['MAX_IMAGE_SIZE'] || 16.megabytes).to_i
  VIDEO_LIMIT = (ENV['MAX_VIDEO_SIZE'] || 99.megabytes).to_i

  MAX_VIDEO_MATRIX_LIMIT = 8_294_400 # 3840x2160px
  MAX_VIDEO_FRAME_RATE   = 120
  MAX_VIDEO_FRAMES       = 36_000 # Approx. 5 minutes at 120 fps

  IMAGE_FILE_EXTENSIONS = %w(.jpg .jpeg .png .gif .webp .heic .heif .avif).freeze
  VIDEO_FILE_EXTENSIONS = %w(.webm .mp4 .m4v .mov).freeze
  AUDIO_FILE_EXTENSIONS = %w(.ogg .oga .mp3 .wav .flac .opus .aac .m4a .3gp .wma).freeze

  META_KEYS = %i(
    focus
    colors
    original
    small
  ).freeze

  IMAGE_MIME_TYPES             = %w(image/jpeg image/png image/gif image/heic image/heif image/webp image/avif).freeze
  IMAGE_CONVERTIBLE_MIME_TYPES = %w(image/heic image/heif image/avif).freeze
  VIDEO_MIME_TYPES             = %w(video/webm video/mp4 video/quicktime video/ogg).freeze
  VIDEO_CONVERTIBLE_MIME_TYPES = %w(video/webm video/quicktime).freeze
  AUDIO_MIME_TYPES             = %w(audio/wave audio/wav audio/x-wav audio/x-pn-wave audio/vnd.wave audio/ogg audio/vorbis audio/mpeg audio/mp3 audio/webm audio/flac audio/aac audio/m4a audio/x-m4a audio/mp4 audio/3gpp video/x-ms-asf).freeze

  BLURHASH_OPTIONS = {
    x_comp: 4,
    y_comp: 4,
  }.freeze

  IMAGE_STYLES = {
    original: {
      pixels: 8_294_400, # 3840x2160px
      file_geometry_parser: FastGeometryParser,
    }.freeze,

    small: {
      pixels: 230_400, # 640x360px
      file_geometry_parser: FastGeometryParser,
      blurhash: BLURHASH_OPTIONS,
    }.freeze,
  }.freeze

  IMAGE_CONVERTED_STYLES = {
    original: {
      format: 'jpeg',
      content_type: 'image/jpeg',
    }.merge(IMAGE_STYLES[:original]).freeze,

    small: {
      format: 'jpeg',
    }.merge(IMAGE_STYLES[:small]).freeze,
  }.freeze

  VIDEO_FORMAT = {
    format: 'mp4',
    content_type: 'video/mp4',
    vfr_frame_rate_threshold: MAX_VIDEO_FRAME_RATE,
    convert_options: {
      output: {
        'loglevel' => 'fatal',
        'preset' => 'veryfast',
        'movflags' => 'faststart', # Move metadata to start of file so playback can begin before download finishes
        'pix_fmt' => 'yuv420p', # Ensure color space for cross-browser compatibility
        'vf' => 'crop=floor(iw/2)*2:floor(ih/2)*2', # h264 requires width and height to be even. Crop instead of scale to avoid blurring
        'c:v' => 'h264',
        'c:a' => 'aac',
        'b:a' => '192k',
        'map_metadata' => '-1',
        'frames:v' => MAX_VIDEO_FRAMES,
      }.freeze,
    }.freeze,
  }.freeze

  VIDEO_PASSTHROUGH_OPTIONS = {
    video_codecs: ['h264'].freeze,
    audio_codecs: ['aac', nil].freeze,
    colorspaces: ['yuv420p'].freeze,
    options: {
      format: 'mp4',
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          'map_metadata' => '-1',
          'c:v' => 'copy',
          'c:a' => 'copy',
        }.freeze,
      }.freeze,
    }.freeze,
  }.freeze

  VIDEO_STYLES = {
    small: {
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          :vf => 'scale=\'min(640\, iw):min(640\, ih)\':force_original_aspect_ratio=decrease',
        }.freeze,
      }.freeze,
      format: 'png',
      time: 0,
      file_geometry_parser: FastGeometryParser,
      blurhash: BLURHASH_OPTIONS,
    }.freeze,

    original: VIDEO_FORMAT.merge(passthrough_options: VIDEO_PASSTHROUGH_OPTIONS).freeze,
  }.freeze

  AUDIO_STYLES = {
    original: {
      format: 'mp3',
      content_type: 'audio/mpeg',
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          'q:a' => 2,
        }.freeze,
      }.freeze,
    }.freeze,
  }.freeze

  VIDEO_CONVERTED_STYLES = {
    small: VIDEO_STYLES[:small].freeze,
    original: VIDEO_FORMAT.freeze,
  }.freeze

  THUMBNAIL_STYLES = {
    original: IMAGE_STYLES[:small].freeze,
  }.freeze

  DEFAULT_STYLES = [:original].freeze

  GLOBAL_CONVERT_OPTIONS = {
    all: '-quality 90 +profile "!icc,*" +set date:modify +set date:create +set date:timestamp -define jpeg:dct-method=float',
  }.freeze

  belongs_to :account,          inverse_of: :media_attachments, optional: true
  belongs_to :status,           inverse_of: :media_attachments, optional: true
  belongs_to :scheduled_status, inverse_of: :media_attachments, optional: true

  has_attached_file :file,
                    styles: ->(f) { file_styles f },
                    processors: ->(f) { file_processors f },
                    convert_options: GLOBAL_CONVERT_OPTIONS

  before_file_validate :set_type_and_extension
  before_file_validate :check_video_dimensions

  validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES
  validates_attachment_size :file, less_than: ->(m) { m.larger_media_format? ? VIDEO_LIMIT : IMAGE_LIMIT }
  remotable_attachment :file, VIDEO_LIMIT, suppress_errors: false, download_on_assign: false, attribute_name: :remote_url

  has_attached_file :thumbnail,
                    styles: THUMBNAIL_STYLES,
                    processors: [:lazy_thumbnail, :blurhash_transcoder, :color_extractor],
                    convert_options: GLOBAL_CONVERT_OPTIONS

  validates_attachment_content_type :thumbnail, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :thumbnail, less_than: IMAGE_LIMIT
  remotable_attachment :thumbnail, IMAGE_LIMIT, suppress_errors: true, download_on_assign: false

  validates :account, presence: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }
  validates :file, presence: true, if: :local?
  validates :thumbnail, absence: true, if: -> { local? && !audio_or_video? }

  scope :attached, -> { where.not(status_id: nil).or(where.not(scheduled_status_id: nil)) }
  scope :cached, -> { remote.where.not(file_file_name: nil) }
  scope :created_before, ->(value) { where(arel_table[:created_at].lt(value)) }
  scope :local, -> { where(remote_url: '') }
  scope :ordered, -> { order(id: :asc) }
  scope :remote, -> { where.not(remote_url: '') }
  scope :unattached, -> { where(status_id: nil, scheduled_status_id: nil) }
  scope :updated_before, ->(value) { where(arel_table[:updated_at].lt(value)) }

  attr_accessor :skip_download

  def local?
    remote_url.blank?
  end

  def not_processed?
    processing.present? && !processing_complete?
  end

  def needs_redownload?
    file.blank? && remote_url.present?
  end

  def significantly_changed?
    description_previously_changed? || thumbnail_updated_at_previously_changed? || file_meta_previously_changed?
  end

  def larger_media_format?
    video? || gifv? || audio?
  end

  def audio_or_video?
    audio? || video?
  end

  def to_param
    shortcode.presence || id&.to_s
  end

  def focus=(point)
    return if point.blank?

    x, y = (point.is_a?(Enumerable) ? point : point.split(',')).map(&:to_f)

    meta = (file.instance_read(:meta) || {}).with_indifferent_access.slice(*META_KEYS)
    meta['focus'] = { 'x' => x, 'y' => y }

    file.instance_write(:meta, meta)
  end

  def focus
    x = file.meta&.dig('focus', 'x')
    y = file.meta&.dig('focus', 'y')

    return if x.nil? || y.nil?

    "#{x},#{y}"
  end

  attr_writer :delay_processing

  def delay_processing?
    @delay_processing && larger_media_format?
  end

  def delay_processing_for_attachment?(attachment_name)
    delay_processing? && attachment_name == :file
  end

  before_create :set_unknown_type
  before_create :set_processing

  after_commit :enqueue_processing, on: :create
  after_commit :reset_parent_cache, on: :update

  after_post_process :set_meta

  class << self
    def supported_mime_types
      IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES
    end

    def supported_file_extensions
      IMAGE_FILE_EXTENSIONS + VIDEO_FILE_EXTENSIONS + AUDIO_FILE_EXTENSIONS
    end

    private

    def file_styles(attachment)
      if attachment.instance.file_content_type == 'image/gif' || VIDEO_CONVERTIBLE_MIME_TYPES.include?(attachment.instance.file_content_type)
        VIDEO_CONVERTED_STYLES
      elsif IMAGE_CONVERTIBLE_MIME_TYPES.include?(attachment.instance.file_content_type)
        IMAGE_CONVERTED_STYLES
      elsif IMAGE_MIME_TYPES.include?(attachment.instance.file_content_type)
        IMAGE_STYLES
      elsif VIDEO_MIME_TYPES.include?(attachment.instance.file_content_type)
        VIDEO_STYLES
      else
        AUDIO_STYLES
      end
    end

    def file_processors(instance)
      if instance.file_content_type == 'image/gif'
        [:gif_transcoder, :blurhash_transcoder]
      elsif VIDEO_MIME_TYPES.include?(instance.file_content_type)
        [:transcoder, :blurhash_transcoder, :type_corrector]
      elsif AUDIO_MIME_TYPES.include?(instance.file_content_type)
        [:image_extractor, :transcoder, :type_corrector]
      else
        [:lazy_thumbnail, :blurhash_transcoder, :type_corrector]
      end
    end
  end

  private

  def set_unknown_type
    self.type = :unknown if file.blank? && !type_changed?
  end

  def set_type_and_extension
    self.type = begin
      if VIDEO_MIME_TYPES.include?(file_content_type)
        :video
      elsif AUDIO_MIME_TYPES.include?(file_content_type)
        :audio
      else
        :image
      end
    end
  end

  def set_processing
    self.processing = delay_processing? ? :queued : :complete
  end

  def check_video_dimensions
    return unless (video? || gifv?) && file.queued_for_write[:original].present?

    movie = ffmpeg_data(file.queued_for_write[:original].path)

    return unless movie.valid?

    raise Mastodon::StreamValidationError, 'Video has no video stream' if movie.width.nil? || movie.frame_rate.nil?
    raise Mastodon::DimensionsValidationError, "#{movie.width}x#{movie.height} videos are not supported" if movie.width * movie.height > MAX_VIDEO_MATRIX_LIMIT
    raise Mastodon::DimensionsValidationError, "#{movie.frame_rate.floor}fps videos are not supported" if movie.frame_rate.floor > MAX_VIDEO_FRAME_RATE
  end

  def set_meta
    file.instance_write :meta, populate_meta
  end

  def populate_meta
    meta = (file.instance_read(:meta) || {}).with_indifferent_access.slice(*META_KEYS)

    file.queued_for_write.each do |style, file|
      meta[style] = style == :small || image? ? image_geometry(file) : video_metadata(file)
    end

    meta[:small] = image_geometry(thumbnail.queued_for_write[:original]) if thumbnail.queued_for_write.key?(:original)

    meta
  end

  def image_geometry(file)
    width, height = FastImage.size(file.path)

    return {} if width.nil?

    {
      width: width,
      height: height,
      size: "#{width}x#{height}",
      aspect: width.to_f / height,
    }
  end

  def video_metadata(file)
    movie = ffmpeg_data(file.path)

    return {} unless movie.valid?

    {
      width: movie.width,
      height: movie.height,
      frame_rate: movie.frame_rate,
      duration: movie.duration,
      bitrate: movie.bitrate,
    }.compact
  end

  # We call this method about 3 different times on potentially different
  # paths but ultimately the same file, so it makes sense to memoize the
  # result while disregarding the path
  def ffmpeg_data(path = nil)
    @ffmpeg_data ||= VideoMetadataExtractor.new(path)
  end

  def enqueue_processing
    PostProcessMediaWorker.perform_async(id) if delay_processing?
  end

  def reset_parent_cache
    Rails.cache.delete("v3:statuses/#{status_id}") if status_id.present?
  end
end
