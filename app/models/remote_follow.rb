# frozen_string_literal: true

class RemoteFollow
  include ActiveModel::Validations

  attr_accessor :acct

  validates :acct, presence: true

  def initialize(attrs = {})
    @acct = attrs[:acct].strip unless attrs[:acct].nil?
  end
end
