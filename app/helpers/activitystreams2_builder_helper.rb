# frozen_string_literal: true

module Activitystreams2BuilderHelper
  # Gets a usable name for an account, using display name or username.
  def account_name(account)
    account.display_name.presence || account.username
  end
end
