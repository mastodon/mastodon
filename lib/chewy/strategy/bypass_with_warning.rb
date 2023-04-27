# frozen_string_literal: true

module Chewy
  class Strategy
    class BypassWithWarning < Base
      def update(...)
        Rails.logger.warn 'Chewy update without a root strategy' unless @warning_issued
        @warning_issued = true
      end
    end
  end
end
