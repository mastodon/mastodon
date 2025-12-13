# frozen_string_literal: true

class Api::V1::InstancesController < Api::V2::InstancesController
  include DeprecationConcern

  deprecate_api '2022-11-14'

  def show
    cache_even_if_authenticated!
    render_with_cache json: InstancePresenter.new, serializer: REST::V1::InstanceSerializer, root: 'instance'
  end
end
