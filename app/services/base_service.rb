# frozen_string_literal: true

class BaseService
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  include RoutingHelper
  # TODO: move this
  include ActivityStreams2BuilderHelper
end
