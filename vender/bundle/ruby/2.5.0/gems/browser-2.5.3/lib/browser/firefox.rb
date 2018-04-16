# frozen_string_literal: true

module Browser
  class Firefox < Base
    def id
      :firefox
    end

    def name
      "Firefox"
    end

    def full_version
      ua[%r[(?:Firefox|FxiOS)/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /Firefox|FxiOS/
    end
  end
end
