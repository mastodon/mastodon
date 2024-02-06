# frozen_string_literal: true

class InitialStateSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :meta, :compose, :accounts,
             :media_attachments, :settings,
             :max_toot_chars, :max_feed_hashtags, :poll_limits,
             :languages

  attribute :critical_updates_pending, if: -> { object&.role&.can?(:view_devops) && SoftwareUpdate.check_enabled? }

  has_one :push_subscription, serializer: REST::WebPushSubscriptionSerializer
  has_one :role, serializer: REST::RoleSerializer

  def max_toot_chars
    StatusLengthValidator::MAX_CHARS
  end

  def max_feed_hashtags
    TagFeed::LIMIT_PER_MODE
  end

  def poll_limits
    {
      max_options: PollValidator::MAX_OPTIONS,
      max_option_chars: PollValidator::MAX_OPTION_CHARS,
      min_expiration: PollValidator::MIN_EXPIRATION,
      max_expiration: PollValidator::MAX_EXPIRATION,
    }
  end

  def meta
    store = default_meta_store

    if object.current_account
      store[:me]                = object.current_account.id.to_s
      store[:unfollow_modal]    = object_account_user.setting_unfollow_modal
      store[:boost_modal]       = object_account_user.setting_boost_modal
      store[:favourite_modal]   = object_account_user.setting_favourite_modal
      store[:delete_modal]      = object_account_user.setting_delete_modal
      store[:auto_play_gif]     = object_account_user.setting_auto_play_gif
      store[:display_media]     = object_account_user.setting_display_media
      store[:expand_spoilers]   = object_account_user.setting_expand_spoilers
      store[:reduce_motion]     = object_account_user.setting_reduce_motion
      store[:disable_swiping]   = object_account_user.setting_disable_swiping
      store[:advanced_layout]   = object_account_user.setting_advanced_layout
      store[:use_blurhash]      = object_account_user.setting_use_blurhash
      store[:use_pending_items] = object_account_user.setting_use_pending_items
      store[:default_content_type] = object_account_user.setting_default_content_type
      store[:system_emoji_font] = object_account_user.setting_system_emoji_font
      store[:show_trends]       = Setting.trends && object_account_user.setting_trends
    else
      store[:auto_play_gif] = Setting.auto_play_gif
      store[:display_media] = Setting.display_media
      store[:reduce_motion] = Setting.reduce_motion
      store[:use_blurhash]  = Setting.use_blurhash
    end

    store[:disabled_account_id] = object.disabled_account.id.to_s if object.disabled_account
    store[:moved_to_account_id] = object.moved_to_account.id.to_s if object.moved_to_account

    store[:owner] = object.owner&.id&.to_s if Rails.configuration.x.single_user_mode

    store
  end

  def compose
    store = {}

    if object.current_account
      store[:me]                = object.current_account.id.to_s
      store[:default_privacy]   = object.visibility || object_account_user.setting_default_privacy
      store[:default_sensitive] = object_account_user.setting_default_sensitive
      store[:default_language]  = object_account_user.preferred_posting_language
    end

    store[:text] = object.text if object.text

    store
  end

  def accounts
    store = {}

    ActiveRecord::Associations::Preloader.new(
      records: [object.current_account, object.admin, object.owner, object.disabled_account, object.moved_to_account].compact,
      associations: [:account_stat, { user: :role, moved_to_account: [:account_stat, { user: :role }] }]
    ).call

    store[object.current_account.id.to_s]  = serialized_account(object.current_account) if object.current_account
    store[object.admin.id.to_s]            = serialized_account(object.admin) if object.admin
    store[object.owner.id.to_s]            = serialized_account(object.owner) if object.owner
    store[object.disabled_account.id.to_s] = serialized_account(object.disabled_account) if object.disabled_account
    store[object.moved_to_account.id.to_s] = serialized_account(object.moved_to_account) if object.moved_to_account

    store
  end

  def media_attachments
    { accept_content_types: MediaAttachment.supported_file_extensions + MediaAttachment.supported_mime_types }
  end

  def languages
    LanguagesHelper::SUPPORTED_LOCALES.map { |(key, value)| [key, value[0], value[1]] }
  end

  private

  def default_meta_store
    {
      access_token: object.token,
      activity_api_enabled: Setting.activity_api_enabled,
      admin: object.admin&.id&.to_s,
      domain: Addressable::IDNA.to_unicode(instance_presenter.domain),
      limited_federation_mode: Rails.configuration.x.limited_federation_mode,
      locale: I18n.locale,
      mascot: instance_presenter.mascot&.file&.url,
      profile_directory: Setting.profile_directory,
      registrations_open: Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode,
      repository: Mastodon::Version.repository,
      search_enabled: Chewy.enabled?,
      single_user_mode: Rails.configuration.x.single_user_mode,
      source_url: instance_presenter.source_url,
      sso_redirect: sso_redirect,
      status_page_url: Setting.status_page_url,
      streaming_api_base_url: Rails.configuration.x.streaming_api_base_url,
      timeline_preview: Setting.timeline_preview,
      title: instance_presenter.title,
      trends_as_landing_page: Setting.trends_as_landing_page,
      trends_enabled: Setting.trends,
      version: instance_presenter.version,
    }
  end

  def object_account_user
    object.current_account.user
  end

  def serialized_account(account)
    ActiveModelSerializers::SerializableResource.new(account, serializer: REST::AccountSerializer)
  end

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end

  def sso_redirect
    "/auth/auth/#{Devise.omniauth_providers[0]}" if ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1
  end
end
