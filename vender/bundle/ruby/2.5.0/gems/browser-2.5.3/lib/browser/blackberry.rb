# frozen_string_literal: true

module Browser
  class BlackBerry < Base
    def id
      :blackberry
    end

    def name
      "BlackBerry"
    end

    def full_version
      ua[%r[BlackBerry[\da-z]+/([\d.]+)], 1] ||
        ua[%r[Version/([\d.]+)], 1] ||
        "0.0"
    end

    def match?
      ua =~ /BlackBerry|BB10/
    end
  end
end
