# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include Pundit

  def pundit_user
    current_account
  end

  def authorize(record, query = nil)
    super
  rescue Pundit::NotAuthorizedError
    if query.nil? ? params[:action] == 'show' : query.to_sym == :show?
      raise Mastodon::NotFound
    end

    authorize record, :show?

    raise Mastodon::NotPermittedError
  end

  def authorize_with(user, record, query)
    Pundit.authorize(user, record, query)
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end
end
