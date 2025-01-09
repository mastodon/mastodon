# frozen_string_literal: true

class Api::V1::Timelines::BaseController < Api::BaseController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  before_action :require_user!, if: :require_auth?

  private

  def require_auth?
    !Setting.timeline_preview
  end

  def pagination_collection
    @statuses
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
