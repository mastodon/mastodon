# frozen_string_literal: true
# == Schema Information
#
# Table name: account_identity_proofs
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  provider          :string           not null
#  provider_username :string           not null
#  token             :text             not null
#  is_valid          :boolean
#  is_live           :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountIdentityProof < ApplicationRecord

  PROVIDER_MAP = {
    keybase: 'Keybase'
  }

  belongs_to :account
  validates :provider, inclusion: { in: PROVIDER_MAP.values }
  validates :provider_username, format: { with: /\A[a-z0-9_]+\z/i }, length: { minimum: 2, maximum: 15 }
  validates :token, format: { with: /\A[a-f0-9]+\z/ }, length: { maximum: 66 }

  scope :keybase, -> { where(provider: PROVIDER_MAP[:keybase]) }
  scope :active, -> { where(is_valid: true, is_live: true) }
  scope :with_account_username, -> { joins(:account).select(:username, "#{AccountIdentityProof.table_name}.*") }

  def keybase?
    provider == PROVIDER_MAP[:keybase]
  end

end
