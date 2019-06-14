# frozen_string_literal: true
# == Schema Information
#
# Table name: account_identity_proofs
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  provider          :string           default(""), not null
#  provider_username :string           default(""), not null
#  token             :text             default(""), not null
#  verified          :boolean          default(FALSE), not null
#  live              :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountIdentityProof < ApplicationRecord
  belongs_to :account

  validates :provider, inclusion: { in: ProofProvider::SUPPORTED_PROVIDERS }
  validates :provider_username, format: { with: /\A[a-z0-9_]+\z/i }, length: { minimum: 2, maximum: 30 }
  validates :provider_username, uniqueness: { scope: [:account_id, :provider] }
  validates :token, format: { with: /\A[a-f0-9]+\z/ }, length: { maximum: 66 }

  validate :validate_with_provider, if: :token_changed?

  scope :active, -> { where(verified: true, live: true) }

  after_commit :queue_worker, if: :saved_change_to_token?

  delegate :refresh!, :on_success_path, :badge, to: :provider_instance

  def provider_instance
    @provider_instance ||= ProofProvider.find(provider, self)
  end

  private

  def queue_worker
    provider_instance.worker_class.perform_async(id)
  end

  def validate_with_provider
    provider_instance.validate!
  end
end
