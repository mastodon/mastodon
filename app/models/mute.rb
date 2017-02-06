# frozen_string_literal: true

class Mute < ApplicationRecord
  include Paginable
  include Streamable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def verb
    destroyed? ? :unmute : :mute
  end

  def target
    target_account
  end

  def object_type
    :person
  end

  def hidden?
    true
  end

  def title
    destroyed? ? "#{account.acct} is no longer muting #{target_account.acct}" : "#{account.acct} muted #{target_account.acct}"
  end
end
