# frozen_string_literal: true

class Instance
  include ActiveModel::Model

  attr_accessor :domain, :accounts_count

  def initialize(account)
    @domain = account.domain
    @accounts_count = account.accounts_count
  end
end
