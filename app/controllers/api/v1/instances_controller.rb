# frozen_string_literal: true

class Api::V1::InstancesController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  vary_by ''

  def show
    cache_even_if_authenticated!
    render_with_cache json: InstancePresenter.new, serializer: REST::V1::InstanceSerializer, root: 'instance'
  end
end
