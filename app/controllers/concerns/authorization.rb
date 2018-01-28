# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include Pundit

  def pundit_user
    current_account
  end

  def authorize(*)
    super
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end

  def authorize_with(user, record, query)
    Pundit.authorize(user, record, query)
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end
end
