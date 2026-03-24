# frozen_string_literal: true

class Api::V1::Admin::BaseController < Api::BaseController
  include Authorization
  include AccountableConcern
end
