# frozen_string_literal: true

module Browser
  class Chrome < Base
    def id
      :chrome
    end

    def name
      "Chrome"
    end

    def full_version
      # Each regex on its own line to enforce precedence.
      ua[%r[Chrome/([\d.]+)], 1] ||
        ua[%r[CriOS/([\d.]+)], 1] ||
        ua[%r[Safari/([\d.]+)], 1] ||
        ua[%r[AppleWebKit/([\d.]+)], 1] ||
        "0.0"
    end

    def match?
      ua =~ /Chrome|CriOS/ && !opera? && !edge?
    end
  end
end
