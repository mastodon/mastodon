# frozen_string_literal: true
class InitialStateSerializer < ActiveModel::Serializer
  attributes :meta, :compose, :accounts,
             :media_attachments, :settings

  has_one :push_subscription, serializer: REST::WebPushSubscriptionSerializer

  def meta
    store = {
      streaming_api_base_url: Rails.configuration.x.streaming_api_base_url,
      access_token: object.token,
      locale: I18n.locale,
      domain: Rails.configuration.x.local_domain,
      title: instance_presenter.site_title,
      admin: object.admin&.id&.to_s,
      search_enabled: Chewy.enabled?,
      repository: Mastodon::Version.repository,
      source_url: Mastodon::Version.source_url,
      version: Mastodon::Version.to_s,
      invites_enabled: Setting.min_invite_role == 'user',
      mascot: instance_presenter.mascot&.file&.url,
      profile_directory: Setting.profile_directory,
      trends: Setting.trends,
    }

    if object.current_account
      configure_meta_with_account(store, object.current_account)
    else
      store[:auto_play_gif] = Setting.auto_play_gif
      store[:display_media] = Setting.display_media
      store[:reduce_motion] = Setting.reduce_motion
      store[:use_blurhash]  = Setting.use_blurhash
      store[:crop_images]   = Setting.crop_images
    end

    store
  end

  def compose
    store = {}

    if object.current_account
      store[:me]                = object.current_account.id.to_s
      store[:default_privacy]   = object.current_account.user.setting_default_privacy
      store[:default_sensitive] = object.current_account.user.setting_default_sensitive
    end

    store[:text] = object.text if object.text

    store
  end

  def accounts
    store = {}
    store[object.current_account.id.to_s] = ActiveModelSerializers::SerializableResource.new(object.current_account, serializer: REST::AccountSerializer) if object.current_account
    store[object.admin.id.to_s]           = ActiveModelSerializers::SerializableResource.new(object.admin, serializer: REST::AccountSerializer) if object.admin
    store
  end

  def media_attachments
    { accept_content_types: MediaAttachment.supported_file_extensions + MediaAttachment.supported_mime_types }
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end

  def configure_meta_with_account(meta, account)
    meta[:me]                = account.id.to_s
    meta[:unfollow_modal]    = account.user.setting_unfollow_modal
    meta[:boost_modal]       = account.user.setting_boost_modal
    meta[:delete_modal]      = account.user.setting_delete_modal
    meta[:auto_play_gif]     = account.user.setting_auto_play_gif
    meta[:display_media]     = account.user.setting_display_media
    meta[:expand_spoilers]   = account.user.setting_expand_spoilers
    meta[:reduce_motion]     = account.user.setting_reduce_motion
    meta[:advanced_layout]   = account.user.setting_advanced_layout
    meta[:use_blurhash]      = account.user.setting_use_blurhash
    meta[:use_pending_items] = account.user.setting_use_pending_items
    meta[:is_staff]          = account.user.staff?
    meta[:trends]            = Setting.trends && account.user.setting_trends
    meta[:crop_images]       = account.user.setting_crop_images
    meta[:email]             = account.user.email
    meta[:tanker_identity]   = account.user.tanker_identity
    meta[:tanker_app_id]     = ENV['TANKER_APP_ID']
  end
end
