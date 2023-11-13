# frozen_string_literal: true

class Api::V1::Instances::BaseController < Api::BaseController
  skip_before_action :require_authenticated_user!,
                     unless: :limited_federation_mode?

  vary_by ''
end
