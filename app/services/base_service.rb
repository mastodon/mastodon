class BaseService
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  include RoutingHelper
  include ApplicationHelper
  include AtomBuilderHelper
end
