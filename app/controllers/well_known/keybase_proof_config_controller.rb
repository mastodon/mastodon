# frozen_string_literal: true

module WellKnown
  class KeybaseProofConfigController < ActionController::Base
    def show
      render json: {}, serializer: ProofProvider::Keybase::ConfigSerializer
    end
  end
end
