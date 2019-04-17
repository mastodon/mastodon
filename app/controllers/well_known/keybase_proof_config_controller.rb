# frozen_string_literal: true

module WellKnown
  class KeybaseProofConfigController < ActionController::Base
    before_action :check_enabled

    def show
      render json: {}, serializer: ProofProvider::Keybase::ConfigSerializer, root: 'keybase_config'
    end

    private

    def check_enabled
      head 404 unless Setting.enable_keybase
    end
  end
end
