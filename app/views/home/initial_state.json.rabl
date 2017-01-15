object false

node(:meta) {
  {
    access_token: @token,
    locale: I18n.locale,
    me: current_account.id,
  }
}

node(:compose) {
  {
    me: current_account.id,
    private: current_account.locked?,
  }
}

node(:accounts) {
  {
    current_account.id => partial('api/v1/accounts/show', object: current_account),
  }
}

node(:settings) { @web_settings }
