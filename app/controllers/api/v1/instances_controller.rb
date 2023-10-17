# frozen_string_literal: true

class Api::V1::InstancesController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :limited_federation_mode?
  skip_around_action :set_locale

  vary_by ''

  # Override `current_user` to avoid reading session cookies unless in whitelist mode
  def current_user
    super if limited_federation_mode?
  end

  def show
    cache_even_if_authenticated!
    render_with_cache json: InstancePresenter.new, serializer: REST::V1::InstanceSerializer, root: 'instance'
  end
end
