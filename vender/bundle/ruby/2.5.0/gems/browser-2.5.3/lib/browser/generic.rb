# frozen_string_literal: true

module Browser
  class Generic < Base
    NAMES = {
      "QuickTime" => "QuickTime",
      "CoreMedia" => "Apple CoreMedia"
    }.freeze

    def id
      :generic
    end

    def name
      infer_name || "Generic Browser"
    end

    def full_version
      ua[%r[(?:QuickTime)/([\d.]+)], 1] ||
        ua[%r[CoreMedia v([\d.]+)], 1] ||
        "0.0"
    end

    def match?
      true
    end

    private

    def infer_name
      (NAMES.find {|key, _| ua.include?(key) } || []).last
    end
  end
end
