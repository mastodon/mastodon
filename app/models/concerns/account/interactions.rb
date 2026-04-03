# frozen_string_literal: true

module Account::Interactions
  extend ActiveSupport::Concern

  included do
    with_options class_name: 'SeveredRelationship', dependent: :destroy do
      has_many :severed_relationships, foreign_key: 'local_account_id', inverse_of: :local_account
      has_many :remote_severed_relationships, foreign_key: 'remote_account_id', inverse_of: :remote_account
    end

    # Hashtag follows
    has_many :tag_follows, inverse_of: :account, dependent: :destroy

    has_many :announcement_mutes, dependent: :destroy
  end

  def blocking_or_domain_blocking?(other_account)
    return true if blocking?(other_account)
    return false if other_account.domain.blank?

    domain_blocking?(other_account.domain)
  end

  def muting_notifications?(other_account)
    mute_relationships.exists?(target_account: other_account, hide_notifications: true)
  end

  def muting_reblogs?(other_account)
    active_relationships.exists?(target_account: other_account, show_reblogs: false)
  end

  def favourited?(status)
    status.proper.favourites.exists?(account: self)
  end

  def bookmarked?(status)
    status.proper.bookmarks.exists?(account: self)
  end

  def reblogged?(status)
    status.proper.reblogs.exists?(account: self)
  end

  def pinned?(status)
    status_pins.exists?(status: status)
  end

  def status_matches_filters(status)
    active_filters = CustomFilter.cached_filters_for(id)
    CustomFilter.apply_cached_filters(active_filters, status)
  end

  def lists_for_local_distribution
    scope = lists.joins(account: :user)
    scope.where.not(list_accounts: { follow_id: nil }).or(scope.where(account_id: id))
      .merge(User.signed_in_recently)
  end

  private

  def preloaded_relation(type, key)
    @preloaded_relations && @preloaded_relations[type] ? @preloaded_relations[type][key].present? : yield
  end
end
