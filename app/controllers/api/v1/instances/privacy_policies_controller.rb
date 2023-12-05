# frozen_string_literal: true

class Api::V1::Instances::PrivacyPoliciesController < Api::V1::Instances::BaseController
  before_action :set_privacy_policy

  def show
    cache_even_if_authenticated!
    render json: @privacy_policy, serializer: REST::PrivacyPolicySerializer
  end

  private

  def set_privacy_policy
    @privacy_policy = PrivacyPolicy.current
  end
end
