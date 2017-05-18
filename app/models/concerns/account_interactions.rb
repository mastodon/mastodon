# frozen_string_literal: true

module AccountInteractions
  extend ActiveSupport::Concern

  class_methods do
    def following_map(target_account_ids, account_id)
      follow_mapping(Follow.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def followed_by_map(target_account_ids, account_id)
      follow_mapping(Follow.where(account_id: target_account_ids, target_account_id: account_id), :account_id)
    end

    def blocking_map(target_account_ids, account_id)
      follow_mapping(Block.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def muting_map(target_account_ids, account_id)
      follow_mapping(Mute.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def requested_map(target_account_ids, account_id)
      follow_mapping(FollowRequest.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end
  end

  included do
    # Follow relations
    has_many :follow_requests, dependent: :destroy

    has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id',        dependent: :destroy
    has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

    has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_account
    has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :account

    # Block relationships
    has_many :block_relationships, class_name: 'Block', foreign_key: 'account_id', dependent: :destroy
    has_many :blocking, -> { order('blocks.id desc') }, through: :block_relationships, source: :target_account
    has_many :blocked_by_relationships, class_name: 'Block', foreign_key: :target_account_id, dependent: :destroy
    has_many :blocked_by, -> { order('blocks.id desc') }, through: :blocked_by_relationships, source: :account

    # Mute relationships
    has_many :mute_relationships, class_name: 'Mute', foreign_key: 'account_id', dependent: :destroy
    has_many :muting, -> { order('mutes.id desc') }, through: :mute_relationships, source: :target_account
    has_many :conversation_mutes, dependent: :destroy
    has_many :domain_blocks, class_name: 'AccountDomainBlock', dependent: :destroy

    def follow!(other_account)
      active_relationships.find_or_create_by!(target_account: other_account)
    end

    def block!(other_account)
      block_relationships.find_or_create_by!(target_account: other_account)
    end

    def mute!(other_account)
      mute_relationships.find_or_create_by!(target_account: other_account)
    end

    def mute_conversation!(conversation)
      conversation_mutes.find_or_create_by!(conversation: conversation)
    end

    def block_domain!(other_domain)
      domain_blocks.find_or_create_by!(domain: other_domain)
    end

    def unfollow!(other_account)
      follow = active_relationships.find_by(target_account: other_account)
      follow&.destroy
    end

    def unblock!(other_account)
      block = block_relationships.find_by(target_account: other_account)
      block&.destroy
    end

    def unmute!(other_account)
      mute = mute_relationships.find_by(target_account: other_account)
      mute&.destroy
    end

    def unmute_conversation!(conversation)
      mute = conversation_mutes.find_by(conversation: conversation)
      mute&.destroy!
    end

    def unblock_domain!(other_domain)
      block = domain_blocks.find_by(domain: other_domain)
      block&.destroy
    end

    def following?(other_account)
      active_relationships.where(target_account: other_account).exists?
    end

    def blocking?(other_account)
      block_relationships.where(target_account: other_account).exists?
    end

    def domain_blocking?(other_domain)
      domain_blocks.where(domain: other_domain).exists?
    end

    def muting?(other_account)
      mute_relationships.where(target_account: other_account).exists?
    end

    def muting_conversation?(conversation)
      conversation_mutes.where(conversation: conversation).exists?
    end

    def requested?(other_account)
      follow_requests.where(target_account: other_account).exists?
    end

    def favourited?(status)
      status.proper.favourites.where(account: self).exists?
    end

    def reblogged?(status)
      status.proper.reblogs.where(account: self).exists?
    end
  end
end
