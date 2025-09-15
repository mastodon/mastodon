# frozen_string_literal: true

module Api::InteractionPoliciesConcern
  extend ActiveSupport::Concern

  def quote_approval_policy
    return nil unless Mastodon::Feature.outgoing_quotes_enabled?

    case status_params[:quote_approval_policy]
    when 'public'
      Status::QUOTE_APPROVAL_POLICY_FLAGS[:public] << 16
    when 'followers'
      Status::QUOTE_APPROVAL_POLICY_FLAGS[:followers] << 16
    when 'nobody'
      0
    when nil
      current_user.setting_default_quote_policy
    else
      # TODO: raise more useful message
      raise ActiveRecord::RecordInvalid
    end
  end
end
