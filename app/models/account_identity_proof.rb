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

require 'keybase_proof'

class AccountIdentityProof < ApplicationRecord

  PROVIDER_MAP = {
    keybase: 'Keybase'
  }

  belongs_to :account
  validates :provider, inclusion: { in: PROVIDER_MAP.values }
  validates :provider_username, format: { with: /\A[a-z0-9_]+\z/i }, length: { minimum: 2, maximum: 15 }
  validates :provider_username, uniqueness: {scope: [:account_id, :provider]}
  validates :token, format: { with: /\A[a-f0-9]+\z/ }, length: { maximum: 66 }
  validate :matches_keybase_validations, if: -> { keybase? }

  scope :keybase, -> { where(provider: PROVIDER_MAP[:keybase]) }
  scope :active, -> { where(is_valid: true, is_live: true) }
  scope :with_account_username, -> { joins(:account).select(:username, "#{AccountIdentityProof.table_name}.*") }

  def keybase?
    provider == PROVIDER_MAP[:keybase]
  end

  def matches_keybase_validations
    errors.add(:base, I18n.t('account_identity_proofs.keybase_errors.token')) unless token.try(:length) == 66
  end

  def save_if_valid_remotely
    if !valid?
      return false
    end
    if keybase? && !valid_in_keybase?
      errors.add(:token, I18n.t('account_identity_proofs.keybase_errors.remote_invalid', kb_username: provider_username))
      return false
    end
    self.is_valid = true
    save
  end

  def valid_in_keybase?
    Keybase::Proof.new(provider_username, account.try(:username), token).is_remote_valid?
  rescue KeyError
    false
  end
end
