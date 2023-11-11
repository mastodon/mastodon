# frozen_string_literal: true

class Api::V1::Trends::BaseController < Api::BaseController
  after_action :insert_pagination_headers
end
