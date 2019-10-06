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
end
