# frozen_string_literal: true

module Status::InteractionPolicyConcern
  extend ActiveSupport::Concern

  included do
    composed_of :quote_interaction_policy, class_name: 'InteractionPolicy', mapping: { quote_approval_policy: :bitmap }

    before_validation :downgrade_quote_policy, if: -> { local? && !distributable? }
  end

  def quote_policy_as_keys(kind)
    raise ArgumentError unless kind.in?(%i(automatic manual))

    sub_policy = quote_interaction_policy.send(kind)
    sub_policy.as_keys
  end

  # Returns `:automatic`, `:manual`, `:unknown` or `:denied`
  def quote_policy_for_account(other_account)
    return :denied if other_account.nil? || direct_visibility? || reblog?

    following_author = nil
    followed_by_author = nil

    # Post author is always allowed to quote themselves
    return :automatic if account_id == other_account.id

    automatic_policy = quote_interaction_policy.automatic

    return :automatic if automatic_policy.public?

    if automatic_policy.followers?
      following_author = other_account.following?(account) if following_author.nil?
      return :automatic if following_author
    end

    if automatic_policy.following?
      followed_by_author = account.following?(other_account) if followed_by_author.nil?
      return :automatic if followed_by_author
    end

    # We don't know we are allowed by the automatic policy, considering the manual one
    manual_policy = quote_interaction_policy.manual

    return :manual if manual_policy.public?

    if manual_policy.followers?
      following_author = other_account.following?(account) if following_author.nil?
      return :manual if following_author
    end

    if manual_policy.following?
      followed_by_author = account.following?(other_account) if followed_by_author.nil?
      return :manual if followed_by_author
    end

    return :unknown if [automatic_policy, manual_policy].any?(&:unsupported_policy?)

    :denied
  end

  def downgrade_quote_policy
    self.quote_approval_policy = 0
  end
end
