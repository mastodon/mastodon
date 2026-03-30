# frozen_string_literal: true

class SEO::SocialMediaPostingSerializer < ActiveModel::Serializer
  include FormattingHelper
  include RoutingHelper

  attributes :context, :type, :url, :date_published, :date_modified,
             :author, :text, :interaction_statistic

  attribute :image, if: -> { object.ordered_media_attachments.any?(&:image?) }
  attribute :video, if: -> { object.ordered_media_attachments.any? { |attachment| attachment.video? || attachment.gifv? } }
  attribute :audio, if: -> { object.ordered_media_attachments.any?(&:audio?) }
  attribute :shared_content, if: -> { object.with_preview_card? }

  def context
    'https://schema.org'
  end

  def type
    'SocialMediaPosting'
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def date_published
    object.created_at.iso8601
  end

  def date_modified
    object.edited_at&.iso8601
  end

  def author
    {
      type: 'Person',
      name: object.account.display_name.presence || object.account.username,
      alternate_name: object.account.local_username_and_domain,
      identifier: object.account.local_username_and_domain,
      url: ActivityPub::TagManager.instance.url_for(object.account),
      interaction_statistic: [
        {
          type: 'InteractionCounter',
          interaction_type: 'https://schema.org/FollowAction',
          user_interaction_count: object.account.followers_count,
        },
      ],
    }
  end

  def text
    status_content_format(object)
  end

  def interaction_statistic
    [
      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/LikeAction',
        user_interaction_count: object.favourites_count,
      },

      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/ShareAction',
        user_interaction_count: object.reblogs_count,
      },

      {
        type: 'InteractionCounter',
        interaction_type: 'https://schema.org/ReplyAction',
        user_interaction_count: object.replies_count,
      },
    ]
  end

  def image
    object.ordered_media_attachments.filter_map do |attachment|
      next unless attachment.image?

      {
        type: 'ImageObject',
        content_url: full_asset_url(attachment.file.url(:original, false)),
        thumbnail_url: attachment.thumbnail.present? ? full_asset_url(attachment.thumbnail.url(:original)) : full_asset_url(attachment.file.url(:small)),
        description: attachment.description,
      }
    end
  end

  def video
    object.ordered_media_attachments.filter_map do |attachment|
      next unless attachment.video? || attachment.gifv?

      {
        type: 'VideoObject',
        upload_date: attachment.created_at.iso8601,
        content_url: full_asset_url(attachment.file.url(:original, false)),
        thumbnail_url: attachment.thumbnail.present? ? full_asset_url(attachment.thumbnail.url(:original)) : full_asset_url(attachment.file.url(:small)),
        embed_url: medium_player_url(attachment),
        description: attachment.description,
      }
    end
  end

  def audio
    object.ordered_media_attachments.filter_map do |attachment|
      next unless attachment.audio?

      {
        type: 'AudioObject',
        upload_date: attachment.created_at.iso8601,
        content_url: full_asset_url(attachment.file.url(:original, false)),
        thumbnail_url: attachment.thumbnail.present? ? full_asset_url(attachment.thumbnail.url(:original)) : full_asset_url(attachment.file.url(:small)),
        embed_url: medium_player_url(attachment),
        description: attachment.description,
      }
    end
  end

  def shared_content
    {
      type: 'WebPage',
      url: object.preview_card.url,
    }
  end
end
