# frozen_string_literal: true

class BaseService
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  include RoutingHelper

  def call(*)
    raise NotImplementedError
  end
end
