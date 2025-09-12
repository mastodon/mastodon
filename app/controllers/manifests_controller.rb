# frozen_string_literal: true

class ManifestsController < PrimitiveController
  # Prevent `active_model_serializer`'s `ActionController::Serialization` from calling `current_user`
  # and thus re-issuing session cookies
  serialization_scope nil

  def show
    expires_in 3.minutes, public: true
    render json: InstancePresenter.new, serializer: ManifestSerializer, root: 'instance'
  end
end
