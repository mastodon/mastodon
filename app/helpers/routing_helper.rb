# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper

  included do
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def full_asset_url(source, options = {})
    source = ActionController::Base.helpers.asset_url(source, options) unless Rails.configuration.x.use_s3

    URI.join(root_url, source).to_s
  end
end
