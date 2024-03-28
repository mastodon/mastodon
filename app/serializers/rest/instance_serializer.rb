# frozen_string_literal: true

class REST::InstanceSerializer < ActiveModel::Serializer
  class ContactSerializer < ActiveModel::Serializer
    attributes :email

    has_one :account, serializer: REST::AccountSerializer
  end

  include RoutingHelper

  attributes :domain, :title, :version, :source_url, :description,
             :usage, :thumbnail, :languages, :configuration,
             :registrations

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

  def usage
    {
      users: {
        active_month: object.active_user_count(4),
      },
    }
  end

  def configuration
    {
      urls: {
        streaming: Rails.configuration.x.streaming_api_base_url,
        status: object.status_page_url,
      },

      vapid: {
        public_key: Rails.configuration.x.vapid_public_key,
      },

      accounts: {
        max_featured_tags: Rails.configuration.x.mastodon.accounts[:max_featured_tags],
      },

      statuses: {
        max_characters: Rails.configuration.x.mastodon.statuses[:max_characters],
        max_media_attachments: 4,
        characters_reserved_per_url: Rails.configuration.x.mastodon.statuses[:url_placeholder_characters],
      },

      media_attachments: {
        supported_mime_types: MediaAttachment.supported_mime_types,
        image_size_limit: MediaAttachment.image_size_limit,
        image_matrix_limit: Attachmentable::MAX_MATRIX_LIMIT,
        video_size_limit: MediaAttachment.video_size_limit,
        video_frame_rate_limit: MediaAttachment::MAX_VIDEO_FRAME_RATE,
        video_matrix_limit: MediaAttachment::MAX_VIDEO_MATRIX_LIMIT,
      },

      polls: {
        max_options: Rails.configuration.x.mastodon.polls[:max_options],
        max_characters_per_option: Rails.configuration.x.mastodon.polls[:max_option_characters],
        min_expiration: PollValidator::MIN_EXPIRATION,
        max_expiration: PollValidator::MAX_EXPIRATION,
      },

      translation: {
        enabled: TranslationService.configured?,
      },
    }
  end

  def registrations
    {
      enabled: registrations_enabled?,
      approval_required: Setting.registrations_mode == 'approved',
      message: registrations_enabled? ? nil : registrations_message,
      url: ENV.fetch('SSO_ACCOUNT_SIGN_UP', nil),
    }
  end

  private

  def registrations_enabled?
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  def registrations_message
    markdown.render(Setting.closed_registrations_message) if Setting.closed_registrations_message.present?
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_images: true)
  end
end
