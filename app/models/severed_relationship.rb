# frozen_string_literal: true

class SeveredRelationship < ApplicationRecord
  belongs_to :relationship_severance_event
  belongs_to :local_account, class_name: 'Account'
  belongs_to :remote_account, class_name: 'Account'

  enum :direction, {
    passive: 0, # analogous to `local_account.passive_relationships`
    active: 1, # analogous to `local_account.active_relationships`
  }

  scope :about_local_account, ->(account) { where(local_account: account) }
  scope :about_remote_account, ->(account) { where(remote_account: account) }

  scope :active, -> { where(direction: :active) }
  scope :passive, -> { where(direction: :passive) }

  def account
    active? ? local_account : remote_account
  end

  def target_account
    active? ? remote_account : local_account
  end
end
