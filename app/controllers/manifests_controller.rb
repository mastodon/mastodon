# frozen_string_literal: true

class ManifestsController < ApplicationController
  skip_before_action :store_current_location

  def show
    render json: InstancePresenter.new, serializer: ManifestSerializer
  end
end
