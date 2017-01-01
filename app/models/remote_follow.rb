# frozen_string_literal: true

class RemoteFollow
  include ActiveModel::Validations

  attr_accessor :acct

  validates :acct, presence: true

  def initialize(attrs = {})
    @acct = attrs[:acct]
  end
end
