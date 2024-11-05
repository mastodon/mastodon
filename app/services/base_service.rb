# frozen_string_literal: true

class BaseService
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  include RoutingHelper

  module Trace
    def call(...)
      MastodonOTELTracer.in_span(self.class.name) do
        super
      end
    end
  end

  def self.inherited(subclass)
    super
    subclass.prepend Trace
  end

  def call(*)
    raise NotImplementedError
  end
end
