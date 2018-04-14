module Responders
  module LocationResponder
    def self.included(_base)
      ActiveSupport::Deprecation.warn "Responders::LocationResponder is enabled by default, " \
                                      "no need to include it", caller
    end
  end
end
