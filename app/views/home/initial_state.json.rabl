object false

node(:meta) do
  {
    streaming_api_base_url: @streaming_api_base_url,
    access_token: @token,
    locale: I18n.locale,
    domain: site_hostname,
    me: current_account.id,
    admin: @admin.try(:id),
    boost_modal: current_account.user.setting_boost_modal,
    delete_modal: current_account.user.setting_delete_modal,
    auto_play_gif: current_account.user.setting_auto_play_gif,
  }
end

node(:compose) do
  {
    me: current_account.id,
    default_privacy: current_account.user.setting_default_privacy,
  }
end

node(:accounts) do
  store = {}
  store[current_account.id] = partial('api/v1/accounts/show', object: current_account)
  store[@admin.id] = partial('api/v1/accounts/show', object: @admin) unless @admin.nil?
  store
end

node(:media_attachments) do
  {
    accept_content_types: MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES
  }
end

node(:settings) { @web_settings }
