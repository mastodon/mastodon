# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    # ... other code ...
  end

  private

  def handle_bad_request
    head 400
  end

  def some_method
    if condition
      do_something
    end
    # Removed empty else-clause as per lint.
  end
end
