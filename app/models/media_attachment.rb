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
#

class MediaAttachment < ApplicationRecord
  self.inheritance_column = nil

  enum type: [:image, :gifv, :video, :unknown, :audio]
  enum processing: [:queued, :in_progress, :complete, :failed], _prefix: true

  MAX_DESCRIPTION_LENGTH = 1_500

  IMAGE_FILE_EXTENSIONS = %w(.jpg .jpeg .png .gif).freeze
  VIDEO_FILE_EXTENSIONS = %w(.webm .mp4 .m4v .mov).freeze
  AUDIO_FILE_EXTENSIONS = %w(.ogg .oga .mp3 .wav .flac .opus .aac .m4a .3gp .wma).freeze

  IMAGE_MIME_TYPES             = %w(image/jpeg image/png image/gif).freeze
  VIDEO_MIME_TYPES             = %w(video/webm video/mp4 video/quicktime video/ogg).freeze
  VIDEO_CONVERTIBLE_MIME_TYPES = %w(video/webm video/quicktime).freeze
  AUDIO_MIME_TYPES             = %w(audio/wave audio/wav audio/x-wav audio/x-pn-wave audio/ogg audio/mpeg audio/mp3 audio/webm audio/flac audio/aac audio/m4a audio/x-m4a audio/mp4 audio/3gpp video/x-ms-asf).freeze

  BLURHASH_OPTIONS = {
    x_comp: 4,
    y_comp: 4,
  }.freeze

  IMAGE_STYLES = {
    original: {
      pixels: 1_638_400, # 1280x1280px
      file_geometry_parser: FastGeometryParser,
    },

    small: {
      pixels: 160_000, # 400x400px
      file_geometry_parser: FastGeometryParser,
      blurhash: BLURHASH_OPTIONS,
    },
  }.freeze

  VIDEO_FORMAT = {
    format: 'mp4',
    content_type: 'video/mp4',
    convert_options: {
      output: {
        'loglevel' => 'fatal',
        'movflags' => 'faststart',
        'pix_fmt' => 'yuv420p',
        'vf' => 'scale=\'trunc(iw/2)*2:trunc(ih/2)*2\'',
        'vsync' => 'cfr',
        'c:v' => 'h264',
        'maxrate' => '1300K',
        'bufsize' => '1300K',
        'frames:v' => 60 * 60 * 3,
        'crf' => 18,
        'map_metadata' => '-1',
      },
    },
  }.freeze

  VIDEO_PASSTHROUGH_OPTIONS = {
    video_codecs: ['h264'],
    audio_codecs: ['aac', nil],
    colorspaces: ['yuv420p'],
    options: {
      format: 'mp4',
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          'map_metadata' => '-1',
          'c:v' => 'copy',
          'c:a' => 'copy',
        },
      },
    },
  }.freeze

  VIDEO_STYLES = {
    small: {
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          vf: 'scale=\'min(400\, iw):min(400\, ih)\':force_original_aspect_ratio=decrease',
        },
      },
      format: 'png',
      time: 0,
      file_geometry_parser: FastGeometryParser,
      blurhash: BLURHASH_OPTIONS,
    },

    original: VIDEO_FORMAT.merge(passthrough_options: VIDEO_PASSTHROUGH_OPTIONS),
  }.freeze

  AUDIO_STYLES = {
    original: {
      format: 'mp3',
      content_type: 'audio/mpeg',
      convert_options: {
        output: {
          'loglevel' => 'fatal',
          'map_metadata' => '-1',
          'q:a' => 2,
        },
      },
    },
  }.freeze

  VIDEO_CONVERTED_STYLES = {
    small: VIDEO_STYLES[:small],
    original: VIDEO_FORMAT,
  }.freeze

  IMAGE_LIMIT = (ENV['MAX_IMAGE_SIZE'] || 10.megabytes).to_i
  VIDEO_LIMIT = (ENV['MAX_VIDEO_SIZE'] || 40.megabytes).to_i

  MAX_VIDEO_MATRIX_LIMIT = 2_304_000 # 1920x1200px
  MAX_VIDEO_FRAME_RATE   = 60

  belongs_to :account,          inverse_of: :media_attachments, optional: true
  belongs_to :status,           inverse_of: :media_attachments, optional: true
  belongs_to :scheduled_status, inverse_of: :media_attachments, optional: true

  has_attached_file :file,
                    styles: ->(f) { file_styles f },
                    processors: ->(f) { file_processors f },
                    convert_options: { all: '-quality 90 -strip +set modify-date +set create-date' }

  validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES
  validates_attachment_size :file, less_than: IMAGE_LIMIT, unless: :larger_media_format?
  validates_attachment_size :file, less_than: VIDEO_LIMIT, if: :larger_media_format?
  remotable_attachment :file, VIDEO_LIMIT, suppress_errors: false

  include Attachmentable

  validates :account, presence: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }, if: :local?
  validates :file, presence: true, if: :local?

  scope :attached,   -> { where.not(status_id: nil).or(where.not(scheduled_status_id: nil)) }
  scope :unattached, -> { where(status_id: nil, scheduled_status_id: nil) }
  scope :local,      -> { where(remote_url: '') }
  scope :remote,     -> { where.not(remote_url: '') }
  scope :cached,     -> { remote.where.not(file_file_name: nil) }

  default_scope { order(id: :asc) }

  def local?
    remote_url.blank?
  end

  def not_processed?
    processing.present? && !processing_complete?
  end

  def needs_redownload?
    file.blank? && remote_url.present?
  end

  def larger_media_format?
    video? || gifv? || audio?
  end

  def audio_or_video?
    audio? || video?
  end

  def to_param
    shortcode
  end

  def focus=(point)
    return if point.blank?

    x, y = (point.is_a?(Enumerable) ? point : point.split(',')).map(&:to_f)

    meta = (file.instance_read(:meta) || {}).with_indifferent_access.slice(:focus, :original, :small)
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
    @delay_processing
  end

  after_commit :enqueue_processing, on: :create
  after_commit :reset_parent_cache, on: :update

  before_create :prepare_description, unless: :local?
  before_create :set_shortcode
  before_create :set_processing
  before_create :set_meta

  before_post_process :set_type_and_extension
  before_post_process :check_video_dimensions

  class << self
    def supported_mime_types
      IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES
    end

    def supported_file_extensions
      IMAGE_FILE_EXTENSIONS + VIDEO_FILE_EXTENSIONS + AUDIO_FILE_EXTENSIONS
    end

    private

    def file_styles(f)
      if f.instance.file_content_type == 'image/gif' || VIDEO_CONVERTIBLE_MIME_TYPES.include?(f.instance.file_content_type)
        VIDEO_CONVERTED_STYLES
      elsif IMAGE_MIME_TYPES.include?(f.instance.file_content_type)
        IMAGE_STYLES
      elsif VIDEO_MIME_TYPES.include?(f.instance.file_content_type)
        VIDEO_STYLES
      else
        AUDIO_STYLES
      end
    end

    def file_processors(f)
      if f.file_content_type == 'image/gif'
        [:gif_transcoder, :blurhash_transcoder]
      elsif VIDEO_MIME_TYPES.include?(f.file_content_type)
        [:video_transcoder, :blurhash_transcoder, :type_corrector]
      elsif AUDIO_MIME_TYPES.include?(f.file_content_type)
        [:transcoder, :type_corrector]
      else
        [:lazy_thumbnail, :blurhash_transcoder, :type_corrector]
      end
    end
  end

  private

  def set_shortcode
    self.type = :unknown if file.blank? && !type_changed?

    return unless local?

    loop do
      self.shortcode = SecureRandom.urlsafe_base64(14)
      break if MediaAttachment.find_by(shortcode: shortcode).nil?
    end
  end

  def prepare_description
    self.description = description.strip[0...MAX_DESCRIPTION_LENGTH] unless description.nil?
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

    movie = FFMPEG::Movie.new(file.queued_for_write[:original].path)

    return unless movie.valid?

    raise Mastodon::DimensionsValidationError, "#{movie.width}x#{movie.height} videos are not supported" if movie.width * movie.height > MAX_VIDEO_MATRIX_LIMIT
    raise Mastodon::DimensionsValidationError, "#{movie.frame_rate.to_i}fps videos are not supported" if movie.frame_rate > MAX_VIDEO_FRAME_RATE
  end

  def set_meta
    file.instance_write :meta, populate_meta
  end

  def populate_meta
    meta = (file.instance_read(:meta) || {}).with_indifferent_access.slice(:focus, :original, :small)

    file.queued_for_write.each do |style, file|
      meta[style] = style == :small || image? ? image_geometry(file) : video_metadata(file)
    end

    meta
  end

  def image_geometry(file)
    width, height = FastImage.size(file.path)

    return {} if width.nil?

    {
      width:  width,
      height: height,
      size: "#{width}x#{height}",
      aspect: width.to_f / height,
    }
  end

  def video_metadata(file)
    movie = FFMPEG::Movie.new(file.path)

    return {} unless movie.valid?

    {
      width: movie.width,
      height: movie.height,
      frame_rate: movie.frame_rate,
      duration: movie.duration,
      bitrate: movie.bitrate,
    }.compact
  end

  def enqueue_processing
    PostProcessMediaWorker.perform_async(id) if delay_processing?
  end

  def reset_parent_cache
    Rails.cache.delete("statuses/#{status_id}") if status_id.present?
  end
end
