# frozen_string_literal: true

module WellKnown
  class KeybaseProofConfigController < ActionController::Base
    def show
      render json: {}, serializer: KeybaseConfigSerializer
    end
  end
end
