# frozen_string_literal: true

class ActivityPub::BaseController < Api::BaseController
  skip_before_action :verify_authenticity_token
end
