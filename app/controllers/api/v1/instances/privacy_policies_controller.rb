# frozen_string_literal: true

class Api::V1::Instances::PrivacyPoliciesController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  before_action :set_privacy_policy

  vary_by ''

  def show
    cache_even_if_authenticated!
    render json: @privacy_policy, serializer: REST::PrivacyPolicySerializer
  end

  private

  def set_privacy_policy
    @privacy_policy = PrivacyPolicy.current
  end
end
