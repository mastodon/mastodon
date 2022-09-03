# frozen_string_literal: true

class Api::V1::Admin::Trends::StatusesController < Api::V1::Trends::StatusesController
  before_action -> { authorize_if_got_token! :'admin:read' }

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def statuses_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.statuses.query
    else
      super
    end
  end
end
