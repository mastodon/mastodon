# frozen_string_literal: true

class Api::V1::Instances::ExtendedDescriptionsController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  before_action :set_extended_description

  def show
    expires_in 3.minutes, public: true
    render json: @extended_description, serializer: REST::ExtendedDescriptionSerializer
  end

  private

  def set_extended_description
    @extended_description = ExtendedDescription.current
  end
end
