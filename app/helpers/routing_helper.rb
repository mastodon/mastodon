module RoutingHelper
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers
  include GrapeRouteHelpers::NamedRouteMatcher

  included do
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end
