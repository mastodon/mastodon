# frozen_string_literal: true

module Activitystreams2BuilderHelper
  def account_name account
    account.display_name.empty? ? account.username : account.display_name
  end
end
