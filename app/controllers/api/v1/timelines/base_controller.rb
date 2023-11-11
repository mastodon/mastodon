# frozen_string_literal: true

class Api::V1::Timelines::BaseController < Api::BaseController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  private

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end
end
