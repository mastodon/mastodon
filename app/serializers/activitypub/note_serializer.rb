# frozen_string_literal: true

class ActivityPub::NoteSerializer < ActivityPub::Serializer
  context_extensions :atom_uri, :conversation, :sensitive, :voters_count

  attributes :id, :type, :summary,
             :in_reply_to, :published, :url,
             :attributed_to, :to, :cc, :sensitive,
             :atom_uri, :in_reply_to_atom_uri,
             :conversation

  attribute :content
  attribute :content_map, if: :language?
  attribute :updated, if: :edited?

  has_many :virtual_attachments, key: :attachment
  has_many :virtual_tags, key: :tag

  has_one :replies, serializer: ActivityPub::CollectionSerializer, if: :local?

  has_many :poll_options, key: :one_of, if: :poll_and_not_multiple?
  has_many :poll_options, key: :any_of, if: :poll_and_multiple?

  attribute :end_time, if: :poll_and_expires?
  attribute :closed, if: :poll_and_expired?

  attribute :voters_count, if: :poll_and_voters_count?

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    object.preloadable_poll ? 'Question' : 'Note'
  end

  def summary
    object.spoiler_text.presence
  end

  def content
    Formatter.instance.format(object)
  end

  def content_map
    { object.language => Formatter.instance.format(object) }
  end

  def replies
    replies = object.self_replies(5).pluck(:id, :uri)
    last_id = replies.last&.first

    ActivityPub::CollectionPresenter.new(
      type: :unordered,
      id: ActivityPub::TagManager.instance.replies_uri_for(object),
      first: ActivityPub::CollectionPresenter.new(
        type: :unordered,
        part_of: ActivityPub::TagManager.instance.replies_uri_for(object),
        items: replies.map(&:second),
        next: last_id ? ActivityPub::TagManager.instance.replies_uri_for(object, page: true, min_id: last_id) : ActivityPub::TagManager.instance.replies_uri_for(object, page: true, only_other_accounts: true)
      )
    )
  end

  def language?
    object.language.present?
  end

  delegate :edited?, to: :object

  def in_reply_to
    return unless object.reply? && !object.thread.nil?

    if object.thread.uri.nil? || object.thread.uri.start_with?('http')
      ActivityPub::TagManager.instance.uri_for(object.thread)
    else
      object.thread.url
    end
  end

  def published
    object.created_at.iso8601
  end

  def updated
    object.edited_at.iso8601
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def attributed_to
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    ActivityPub::TagManager.instance.to(object)
  end

  def cc
    ActivityPub::TagManager.instance.cc(object)
  end

  def sensitive
    object.account.sensitized? || object.sensitive
  end

  def virtual_attachments
    object.ordered_media_attachments
  end

  def virtual_tags
    object.active_mentions.to_a.sort_by(&:id) + object.tags + object.emojis
  end

  def atom_uri
    return unless object.local?

    OStatus::TagManager.instance.uri_for(object)
  end

  def in_reply_to_atom_uri
    return unless object.reply? && !object.thread.nil?

    OStatus::TagManager.instance.uri_for(object.thread)
  end

  def conversation
    return if object.conversation.nil?

    if object.conversation.uri?
      object.conversation.uri
    else
      OStatus::TagManager.instance.unique_tag(object.conversation.created_at, object.conversation.id, 'Conversation')
    end
  end

  def local?
    object.account.local?
  end

  def poll_options
    object.preloadable_poll.loaded_options
  end

  def poll_and_multiple?
    object.preloadable_poll&.multiple?
  end

  def poll_and_not_multiple?
    object.preloadable_poll && !object.preloadable_poll.multiple?
  end

  def closed
    object.preloadable_poll.expires_at.iso8601
  end

  alias end_time closed

  def voters_count
    object.preloadable_poll.voters_count
  end

  def poll_and_expires?
    object.preloadable_poll&.expires_at&.present?
  end

  def poll_and_expired?
    object.preloadable_poll&.expired?
  end

  def poll_and_voters_count?
    object.preloadable_poll&.voters_count
  end

  class MediaAttachmentSerializer < ActivityPub::Serializer
    context_extensions :blurhash, :focal_point

    include RoutingHelper

    attributes :type, :media_type, :url, :name, :blurhash
    attribute :focal_point, if: :focal_point?
    attribute :width, if: :width?
    attribute :height, if: :height?

    has_one :icon, serializer: ActivityPub::ImageSerializer, if: :thumbnail?

    def type
      'Document'
    end

    def name
      object.description
    end

    def media_type
      object.file_content_type
    end

    def url
      object.local? ? full_asset_url(object.file.url(:original, false)) : object.remote_url
    end

    def focal_point?
      object.file.meta.is_a?(Hash) && object.file.meta['focus'].is_a?(Hash)
    end

    def focal_point
      [object.file.meta['focus']['x'], object.file.meta['focus']['y']]
    end

    def icon
      object.thumbnail
    end

    def thumbnail?
      object.thumbnail.present?
    end

    def width?
      object.file.meta&.dig('original', 'width').present?
    end

    def height?
      object.file.meta&.dig('original', 'height').present?
    end

    def width
      object.file.meta.dig('original', 'width')
    end

    def height
      object.file.meta.dig('original', 'height')
    end
  end

  class MentionSerializer < ActivityPub::Serializer
    attributes :type, :href, :name

    def type
      'Mention'
    end

    def href
      ActivityPub::TagManager.instance.uri_for(object.account)
    end

    def name
      "@#{object.account.acct}"
    end
  end

  class TagSerializer < ActivityPub::Serializer
    context_extensions :hashtag

    include RoutingHelper

    attributes :type, :href, :name

    def type
      'Hashtag'
    end

    def href
      tag_url(object)
    end

    def name
      "##{object.name}"
    end
  end

  class CustomEmojiSerializer < ActivityPub::EmojiSerializer
  end

  class OptionSerializer < ActivityPub::Serializer
    class RepliesSerializer < ActivityPub::Serializer
      attributes :type, :total_items

      def type
        'Collection'
      end

      def total_items
        object.votes_count
      end
    end

    attributes :type, :name

    has_one :replies, serializer: ActivityPub::NoteSerializer::OptionSerializer::RepliesSerializer

    def type
      'Note'
    end

    def name
      object.title
    end

    def replies
      object
    end
  end
end
