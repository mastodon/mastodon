# frozen_string_literal: true

class BlockedRelationshipMap
  attr_reader :current_account, :account

  def initialize(current_account, account)
    @current_account = current_account
    @account = account
  end

  def following
    { account.id => false }
  end

  def followed_by
    { account.id => false }
  end

  def blocking
    { account.id => true }
  end

  def muting
    { account.id => muting_account? }
  end

  def requested
    { account.id => false }
  end

  def domain_blocking
    { account.id => domain_blocking? }
  end

  private

  def muting_account?
    current_account.muting?(account.id)
  end

  def domain_blocking?
    current_account.domain_blocking?(account.domain)
  end
end
