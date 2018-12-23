# frozen_string_literal: true

class ManifestsController < ApplicationController
  def show
    render json: InstancePresenter.new, serializer: ManifestSerializer
  end
end
