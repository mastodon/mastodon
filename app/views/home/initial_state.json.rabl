object false

node(:meta) do
  {
    access_token: @token,
    locale: I18n.locale,
    me: current_account.id,
    boost_modal: current_account.user.setting_boost_modal,
  }
end

node(:compose) do
  {
    me: current_account.id,
    default_privacy: current_account.user.setting_default_privacy,
  }
end

node(:accounts) do
  {
    current_account.id => partial('api/v1/accounts/show', object: current_account),
  }
end

node(:settings) { @web_settings }
