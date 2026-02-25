# frozen_string_literal: true

class REST::InstanceSerializer < ActiveModel::Serializer
  class ContactSerializer < ActiveModel::Serializer
    attributes :email

    has_one :account, serializer: REST::AccountSerializer
  end

  include InstanceHelper
  include RoutingHelper

  attributes :domain, :title, :version, :source_url, :description,
             :usage, :thumbnail, :icon, :languages, :configuration,
             :registrations, :api_versions, :wrapstodon

  has_one :contact, serializer: ContactSerializer
  has_many :rules, serializer: REST::RuleSerializer

  def thumbnail
    if object.thumbnail
      {
        url: full_asset_url(object.thumbnail.file.url(:'@1x')),
        blurhash: object.thumbnail.blurhash,
        versions: {
          '@1x': full_asset_url(object.thumbnail.file.url(:'@1x')),
          '@2x': full_asset_url(object.thumbnail.file.url(:'@2x')),
        },
      }
    else
      {
        url: frontend_asset_url('images/preview.png'),
      }
    end
  end

  def icon
    SiteUpload::ANDROID_ICON_SIZES.map do |size|
      src = app_icon_path(size.to_i)
      src = URI.join(root_url, src).to_s if src.present?

      {
        src: src || frontend_asset_url("icons/android-chrome-#{size}x#{size}.png"),
        size: "#{size}x#{size}",
      }
    end
  end

  def usage
    {
      users: {
        active_month: limited_federation? ? 0 : object.active_user_count(4),
      },
    }
  end

  def configuration
    {
      urls: {
        streaming: Rails.configuration.x.streaming_api_base_url,
        status: object.status_page_url,
        about: about_url,
        privacy_policy: privacy_policy_url,
        terms_of_service: TermsOfService.current.present? ? terms_of_service_url : nil,
      },

      vapid: {
        public_key: Rails.configuration.x.vapid.public_key,
      },

      accounts: {
        max_featured_tags: FeaturedTag::LIMIT,
        max_pinned_statuses: StatusPinValidator::PIN_LIMIT,
        max_profile_fields: Account::DEFAULT_FIELDS_SIZE,
        profile_field_name_limit: Account::Field::MAX_CHARACTERS_LOCAL,
        profile_field_value_limit: Account::Field::MAX_CHARACTERS_LOCAL,
      },

      statuses: {
        max_characters: StatusLengthValidator::MAX_CHARS,
        max_media_attachments: Status::MEDIA_ATTACHMENTS_LIMIT,
        characters_reserved_per_url: StatusLengthValidator::URL_PLACEHOLDER_CHARS,
      },

      media_attachments: {
        description_limit: MediaAttachment::MAX_DESCRIPTION_LENGTH,
        image_matrix_limit: Attachmentable::MAX_MATRIX_LIMIT,
        image_size_limit: MediaAttachment::IMAGE_LIMIT,
        supported_mime_types: MediaAttachment.supported_mime_types,
        video_frame_rate_limit: MediaAttachment::MAX_VIDEO_FRAME_RATE,
        video_matrix_limit: MediaAttachment::MAX_VIDEO_MATRIX_LIMIT,
        video_size_limit: MediaAttachment::VIDEO_LIMIT,
      },

      polls: {
        max_options: PollOptionsValidator::MAX_OPTIONS,
        max_characters_per_option: PollOptionsValidator::MAX_OPTION_CHARS,
        min_expiration: PollExpirationValidator::MIN_EXPIRATION,
        max_expiration: PollExpirationValidator::MAX_EXPIRATION,
      },

      translation: {
        enabled: TranslationService.configured?,
      },

      timelines_access: {
        live_feeds: {
          local: Setting.local_live_feed_access,
          remote: Setting.remote_live_feed_access,
        },
        hashtag_feeds: {
          local: Setting.local_topic_feed_access,
          remote: Setting.remote_topic_feed_access,
        },
        trending_link_feeds: {
          local: Setting.local_topic_feed_access,
          remote: Setting.remote_topic_feed_access,
        },
      },

      limited_federation: limited_federation?,
    }
  end

  def registrations
    {
      enabled: registrations_enabled?,
      approval_required: Setting.registrations_mode == 'approved',
      reason_required: Setting.registrations_mode == 'approved' && Setting.require_invite_text,
      message: registrations_enabled? ? nil : registrations_message,
      min_age: Setting.min_age.presence,
      url: ENV.fetch('SSO_ACCOUNT_SIGN_UP', nil),
    }
  end

  def api_versions
    Mastodon::Version.api_versions
  end

  def wrapstodon
    AnnualReport.current_campaign
  end

  private

  def registrations_enabled?
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  def registrations_message
    markdown.render(Setting.closed_registrations_message) if Setting.closed_registrations_message.present?
  end

  def limited_federation?
    Rails.configuration.x.mastodon.limited_federation_mode
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_images: true)
  end
end
