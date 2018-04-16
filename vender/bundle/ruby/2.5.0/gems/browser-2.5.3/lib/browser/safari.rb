# frozen_string_literal: true

module Browser
  class Safari < Base
    def id
      :safari
    end

    def name
      "Safari"
    end

    def full_version
      ua[%r[Version/([\d.]+)], 1] ||
        ua[%r[Safari/([\d.]+)], 1] ||
        ua[%r[AppleWebKit/([\d.]+)], 1] ||
        "0.0"
    end

    def match?
      ua =~ /Safari/ && ua !~ /Chrome|CriOS|PhantomJS|FxiOS/
    end
  end
end
