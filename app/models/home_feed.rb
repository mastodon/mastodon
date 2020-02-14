# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @type    = :home
    @id      = account.id
    @account = account
  end

  def regenerating?
    redis.exists("account:#{@id}:regeneration")
  end

  protected

  def status_scope
    [:not_hidden, @account]
  end
end
