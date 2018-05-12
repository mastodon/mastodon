# frozen_string_literal: true

class Web::NotificationSerializer < ActiveModel::Serializer
  include RoutingHelper
  include StreamEntriesHelper

  class DataSerializer < ActiveModel::Serializer
    include RoutingHelper
    include StreamEntriesHelper
    include ActionView::Helpers::SanitizeHelper

    attributes :content, :nsfw, :url, :actions,
               :access_token, :message, :dir

    def content
      decoder.decode(strip_tags(body))
    end

    def dir
      rtl?(body) ? 'rtl' : 'ltr'
    end

    def nsfw
      return if object.target_status.nil?
      object.target_status.spoiler_text.presence
    end

    def url
      case object.type
      when :mention
        web_url("statuses/#{object.target_status.id}")
      when :follow
        web_url("accounts/#{object.from_account.id}")
      when :favourite
        web_url("statuses/#{object.target_status.id}")
      when :reblog
        web_url("statuses/#{object.target_status.id}")
      end
    end

    def actions
      return @actions if defined?(@actions)

      @actions = []

      if object.type == :mention
        @actions << expand_action if collapsed?
        @actions << favourite_action
        @actions << reblog_action if rebloggable?
      end

      @actions
    end

    def access_token
      return if actions.empty?
      current_push_subscription.associated_access_token
    end

    def message
      I18n.t('push_notifications.group.title')
    end

    private

    def body
      case object.type
      when :mention
        object.target_status.text
      when :follow
        object.from_account.note
      when :favourite
        object.target_status.text
      when :reblog
        object.target_status.text
      end
    end

    def decoder
      @decoder ||= HTMLEntities.new
    end

    def expand_action
      {
        title: I18n.t('push_notifications.mention.action_expand'),
        icon: full_asset_url('web-push-icon_expand.png', skip_pipeline: true),
        todo: 'expand',
        action: 'expand',
      }
    end

    def favourite_action
      {
        title: I18n.t('push_notifications.mention.action_favourite'),
        icon: full_asset_url('web-push-icon_favourite.png', skip_pipeline: true),
        todo: 'request',
        method: 'POST',
        action: "/api/v1/statuses/#{object.target_status.id}/favourite",
      }
    end

    def reblog_action
      {
        title: I18n.t('push_notifications.mention.action_boost'),
        icon: full_asset_url('web-push-icon_reblog.png', skip_pipeline: true),
        todo: 'request',
        method: 'POST',
        action: "/api/v1/statuses/#{object.target_status.id}/reblog",
      }
    end

    def collapsed?
      !object.target_status.nil? && (object.target_status.sensitive? || object.target_status.spoiler_text.present?)
    end

    def rebloggable?
      !object.target_status.nil? && !object.target_status.hidden?
    end
  end

  attributes :title, :image, :badge, :tag,
             :timestamp, :icon

  has_one :data, serializer: DataSerializer

  def title
    case object.type
    when :mention
      I18n.t('push_notifications.mention.title', name: name)
    when :follow
      I18n.t('push_notifications.follow.title', name: name)
    when :favourite
      I18n.t('push_notifications.favourite.title', name: name)
    when :reblog
      I18n.t('push_notifications.reblog.title', name: name)
    end
  end

  def image
    return if object.target_status.nil? || object.target_status.media_attachments.empty?
    full_asset_url(object.target_status.media_attachments.first.file.url(:small))
  end

  def badge
    full_asset_url('badge.png', skip_pipeline: true)
  end

  def tag
    object.id
  end

  def timestamp
    object.created_at
  end

  def icon
    object.from_account.avatar_static_url
  end

  def data
    object
  end

  private

  def name
    display_name(object.from_account)
  end
end
