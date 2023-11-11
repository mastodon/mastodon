# frozen_string_literal: true

class Api::V1::Timelines::BaseController < Api::BaseController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }
end
