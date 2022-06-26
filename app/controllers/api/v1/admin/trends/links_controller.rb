# frozen_string_literal: true

class Api::V1::Admin::Trends::LinksController < Api::V1::Trends::LinksController
  before_action -> { authorize_if_got_token! :'admin:read' }

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def links_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.links.query
    else
      super
    end
  end
end
