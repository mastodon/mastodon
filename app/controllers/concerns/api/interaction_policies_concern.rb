# frozen_string_literal: true

module Api::InteractionPoliciesConcern
  extend ActiveSupport::Concern

  def quote_approval_policy
    # TODO: handle `nil` separately
    return nil unless Mastodon::Feature.outgoing_quotes_enabled? && status_params[:quote_approval_policy].present?

    case status_params[:quote_approval_policy]
    when 'public'
      Status::QUOTE_APPROVAL_POLICY_FLAGS[:public] << 16
    when 'followers'
      Status::QUOTE_APPROVAL_POLICY_FLAGS[:followers] << 16
    when 'nobody'
      0
    else
      # TODO: raise more useful message
      raise ActiveRecord::RecordInvalid
    end
  end
end
