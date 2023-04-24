# frozen_string_literal: true

class ManifestsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show
    expires_in 3.minutes, public: true
    render json: InstancePresenter.new, serializer: ManifestSerializer, root: 'instance'
  end
end
