# frozen_string_literal: true

class Api::V1::Instances::ExtendedDescriptionsController < Api::V1::Instances::BaseController
  skip_around_action :set_locale

  before_action :set_extended_description

  # Override `current_user` to avoid reading session cookies unless in limited federation mode
  def current_user
    super if limited_federation_mode?
  end

  def show
    cache_even_if_authenticated!
    render json: @extended_description, serializer: REST::ExtendedDescriptionSerializer
  end

  private

  def set_extended_description
    @extended_description = ExtendedDescription.current
  end
end
