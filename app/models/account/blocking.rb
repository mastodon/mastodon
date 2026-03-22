# frozen_string_literal: true

module Account::Blocking
  extend ActiveSupport::Concern

  included do
    # Block relationships
    with_options class_name: 'Block', dependent: :destroy do
      has_many :block_relationships, foreign_key: :account_id, inverse_of: :account
      has_many :blocked_by_relationships, foreign_key: :target_account_id, inverse_of: :target_account
    end

    has_many :blocking, -> { order(blocks: { id: :desc }) }, through: :block_relationships, source: :target_account
    has_many :blocked_by, -> { order(blocks: { id: :desc }) }, through: :blocked_by_relationships, source: :account
  end

  def block!(target_account, uri: nil)
    block_relationships
      .create_with(uri: uri)
      .find_or_create_by!(target_account:)
  end

  def unblock!(target_account)
    block_relationships
      .find_by(target_account:)
      &.destroy
  end

  def blocking?(target_account)
    other_id = target_account.is_a?(Account) ? target_account.id : target_account

    preloaded_relation(:blocking, other_id) do
      block_relationships.exists?(target_account:)
    end
  end

  def blocked_by?(target_account)
    other_id = target_account.is_a?(Account) ? target_account.id : target_account

    preloaded_relation(:blocked_by, other_id) do
      target_account.block_relationships.exists?(target_account: self)
    end
  end
end
