# frozen_string_literal: true

module WellKnown
  class KeybaseProofConfigController < ActionController::Base
    def show
      render json: {}, serializer: ProofProvider::Keybase::ConfigSerializer, root: 'keybase_config'
    end
  end
end
