# frozen_string_literal: true

module Account::InteractionPolicyConcern
  extend ActiveSupport::Concern

  included do
    composed_of :feature_interaction_policy, class_name: 'InteractionPolicy', mapping: { feature_approval_policy: :bitmap }
  end

  def feature_policy_as_keys(kind)
    raise ArgumentError unless kind.in?(%i(automatic manual))
    return local_feature_policy(kind) if local?

    sub_policy = feature_interaction_policy.send(kind)
    sub_policy.as_keys
  end

  # Returns `:automatic`, `:manual`, `:unknown`, ':missing` or `:denied`
  def feature_policy_for_account(other_account)
    return :denied if other_account.nil? || (local? && !discoverable?)
    return :automatic if local?
    # Post author is always allowed to feature themselves
    return :automatic if self == other_account
    return :missing if feature_approval_policy.zero?

    automatic_policy = feature_interaction_policy.automatic
    following_self = nil
    followed_by_self = nil

    return :automatic if automatic_policy.public?

    if automatic_policy.followers?
      following_self = followed_by?(other_account)
      return :automatic if following_self
    end

    if automatic_policy.following?
      followed_by_self = following?(other_account)
      return :automatic if followed_by_self
    end

    # We don't know we are allowed by the automatic policy, considering the manual one
    manual_policy = feature_interaction_policy.manual

    return :manual if manual_policy.public?

    if manual_policy.followers?
      following_self = followed_by?(other_account) if following_self.nil?
      return :manual if following_self
    end

    if manual_policy.following?
      followed_by_self = following?(other_account) if followed_by_self.nil?
      return :manual if followed_by_self
    end

    return :unknown if [automatic_policy, manual_policy].any?(&:unsupported_policy?)

    :denied
  end

  private

  def local_feature_policy(kind)
    return [] if kind == :manual || !discoverable?

    [:public]
  end
end
