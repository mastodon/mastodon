# frozen_string_literal: true

class InitialStateSerializer < ActiveModel::Serializer
  attributes :meta, :compose, :accounts,
             :media_attachments, :settings

  def meta
    {
      streaming_api_base_url: Rails.configuration.x.streaming_api_base_url,
      access_token: object.token,
      locale: I18n.locale,
      domain: Rails.configuration.x.local_domain,
      me: object.current_account.id,
      admin: object.admin&.id,
      boost_modal: object.current_account.user.setting_boost_modal,
      delete_modal: object.current_account.user.setting_delete_modal,
      auto_play_gif: object.current_account.user.setting_auto_play_gif,
      system_font_ui: object.current_account.user.setting_system_font_ui,
    }
  end

  def compose
    {
      me: object.current_account.id,
      default_privacy: object.current_account.user.setting_default_privacy,
    }
  end

  def accounts
    store = {}
    store[object.current_account.id] = ActiveModelSerializers::SerializableResource.new(object.current_account, serializer: REST::AccountSerializer)
    store[object.admin.id]           = ActiveModelSerializers::SerializableResource.new(object.admin, serializer: REST::AccountSerializer) unless object.admin.nil?
    store
  end

  def media_attachments
    { accept_content_types: MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES }
  end
end
