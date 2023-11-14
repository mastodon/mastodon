# frozen_string_literal: true

class Api::V1::Timelines::BaseController < Api::BaseController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  private

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end

  def next_path_params
    permitted_params.merge(max_id: pagination_max_id)
  end

  def prev_path_params
    permitted_params.merge(min_id: pagination_since_id)
  end

  def permitted_params
    params
      .slice(*self.class::PERMITTED_PARAMS)
      .permit(*self.class::PERMITTED_PARAMS)
  end
end
