# frozen_string_literal: true

module Account::Following
  extend ActiveSupport::Concern

  included do
    # Follow relations
    has_many :follow_requests, dependent: :destroy

    with_options class_name: 'Follow', dependent: :destroy do
      has_many :active_relationships,  foreign_key: :account_id, inverse_of: :account
      has_many :passive_relationships, foreign_key: :target_account_id, inverse_of: :target_account
    end

    has_many :following, -> { order(follows: { id: :desc }) }, through: :active_relationships,  source: :target_account
    has_many :followers, -> { order(follows: { id: :desc }) }, through: :passive_relationships, source: :account
  end

  def follow!(account, **)
    process_follow(active_relationships, account, **)
  end

  def request_follow!(account, **)
    process_follow(follow_requests, account, **)
  end

  def unfollow!(target_account)
    active_relationships
      .find_by(target_account:)
      &.destroy
  end

  def following?(target_account)
    other_id = target_account.is_a?(Account) ? target_account.id : target_account

    preloaded_relation(:following, other_id) do
      active_relationships.exists?(target_account:)
    end
  end

  def following_anyone?
    active_relationships.exists?
  end

  def not_following_anyone?
    !following_anyone?
  end

  def followed_by?(target_account)
    target_account.following?(self)
  end

  def requested?(target_account)
    follow_requests.exists?(target_account:)
  end

  def followers_for_local_distribution
    followers
      .local
      .joins(:user)
      .merge(User.signed_in_recently)
  end

  private

  def process_follow(association, target_account, reblogs: nil, notify: nil, languages: nil, uri: nil, rate_limit: false, bypass_limit: false)
    association
      .create_with(
        bypass_follow_limit: bypass_limit,
        languages:,
        notify: notify.nil? ? false : notify,
        rate_limit:,
        show_reblogs: reblogs.nil? || reblogs,
        uri:
      )
      .find_or_create_by!(target_account:)
      .tap do |record|
        # When record created, this is a no-op since all values will match
        # When updating existing, apply any changes from the args
        record.languages = languages unless languages.nil?
        record.notify = notify unless notify.nil?
        record.show_reblogs = reblogs unless reblogs.nil?

        # Optionally save when we are updating existing and values differ
        record.save! if record.changed?
    end
  end
end
