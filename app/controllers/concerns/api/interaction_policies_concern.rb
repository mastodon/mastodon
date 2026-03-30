# frozen_string_literal: true

module Api::InteractionPoliciesConcern
  extend ActiveSupport::Concern

  def quote_approval_policy
    case status_params[:quote_approval_policy].presence || current_user.setting_default_quote_policy
    when 'public'
      InteractionPolicy::POLICY_FLAGS[:public] << 16
    when 'followers'
      InteractionPolicy::POLICY_FLAGS[:followers] << 16
    when 'nobody'
      0
    else
      # TODO: raise more useful message
      raise ActiveRecord::RecordInvalid
    end
  end
end
