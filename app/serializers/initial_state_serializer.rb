# frozen_string_literal: true

class InitialStateSerializer < ActiveModel::Serializer
  attributes :meta, :compose, :accounts,
             :media_attachments, :settings, :push_subscription

  def meta
    store = {
      streaming_api_base_url: Rails.configuration.x.streaming_api_base_url,
      access_token: object.token,
      locale: I18n.locale,
      domain: Rails.configuration.x.local_domain,
      admin: object.admin&.id,
    }

    if object.current_account
      store[:me]             = object.current_account.id
      store[:unfollow_modal] = object.current_account.user.setting_unfollow_modal
      store[:boost_modal]    = object.current_account.user.setting_boost_modal
      store[:delete_modal]   = object.current_account.user.setting_delete_modal
      store[:auto_play_gif]  = object.current_account.user.setting_auto_play_gif
      store[:system_font_ui] = object.current_account.user.setting_system_font_ui
    end

    store
  end

  def compose
    store = {}

    if object.current_account
      store[:me]                = object.current_account.id
      store[:default_privacy]   = object.current_account.user.setting_default_privacy
      store[:default_sensitive] = object.current_account.user.setting_default_sensitive
    end

    store
  end

  def accounts
    store = {}
    store[object.current_account.id] = ActiveModelSerializers::SerializableResource.new(object.current_account, serializer: REST::AccountSerializer) if object.current_account
    store[object.admin.id]           = ActiveModelSerializers::SerializableResource.new(object.admin, serializer: REST::AccountSerializer) if object.admin
    store
  end

  def media_attachments
    { accept_content_types: MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES }
  end
end
