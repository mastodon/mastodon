# frozen_string_literal: true

module Status::InteractionPolicyConcern
  extend ActiveSupport::Concern

  QUOTE_APPROVAL_POLICY_FLAGS = {
    unsupported_policy: (1 << 0),
    public: (1 << 1),
    followers: (1 << 2),
    following: (1 << 3),
  }.freeze

  included do
    before_validation :downgrade_quote_policy, if: -> { local? && !distributable? }
  end

  def quote_policy_as_keys(kind)
    case kind
    when :automatic
      policy = quote_approval_policy >> 16
    when :manual
      policy = quote_approval_policy & 0xFFFF
    end

    QUOTE_APPROVAL_POLICY_FLAGS.keys.select { |key| policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[key]) }.map(&:to_s)
  end

  # Returns `:automatic`, `:manual`, `:unknown` or `:denied`
  def quote_policy_for_account(other_account)
    return :denied if other_account.nil? || direct_visibility? || reblog?

    following_author = nil
    followed_by_author = nil

    # Post author is always allowed to quote themselves
    return :automatic if account_id == other_account.id

    automatic_policy = quote_approval_policy >> 16
    manual_policy = quote_approval_policy & 0xFFFF

    return :automatic if automatic_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:public])

    if automatic_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:followers])
      following_author = other_account.following?(account) if following_author.nil?
      return :automatic if following_author
    end

    if automatic_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:following])
      followed_by_author = account.following?(other_account) if followed_by_author.nil?
      return :automatic if followed_by_author
    end

    # We don't know we are allowed by the automatic policy, considering the manual one
    return :manual if manual_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:public])

    if manual_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:followers])
      following_author = other_account.following?(account) if following_author.nil?
      return :manual if following_author
    end

    if manual_policy.anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:following])
      followed_by_author = account.following?(other_account) if followed_by_author.nil?
      return :manual if followed_by_author
    end

    return :unknown if (automatic_policy | manual_policy).anybits?(QUOTE_APPROVAL_POLICY_FLAGS[:unsupported_policy])

    :denied
  end

  def downgrade_quote_policy
    self.quote_approval_policy = 0
  end
end
