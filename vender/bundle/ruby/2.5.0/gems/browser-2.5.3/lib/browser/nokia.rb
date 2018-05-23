# frozen_string_literal: true

module Browser
  class Nokia < Base
    def id
      :nokia
    end

    def name
      "Nokia S40 Ovi Browser"
    end

    def full_version
      ua[%r[S40OviBrowser/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /S40OviBrowser/
    end
  end
end
