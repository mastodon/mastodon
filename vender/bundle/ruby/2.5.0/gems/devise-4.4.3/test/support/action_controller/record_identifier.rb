# frozen_string_literal: true

# Since webrat uses ActionController::RecordIdentifier class that was moved to
# ActionView namespace in Rails 4.1+

unless defined?(ActionController::RecordIdentifier)
  require 'action_view/record_identifier'

  module ActionController
    RecordIdentifier = ActionView::RecordIdentifier
  end
end
