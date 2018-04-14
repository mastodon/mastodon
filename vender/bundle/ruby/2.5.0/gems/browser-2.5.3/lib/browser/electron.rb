# frozen_string_literal: true

module Browser
  class Electron < Base
    def id
      :electron
    end

    def name
      "Electron"
    end

    def full_version
      ua[%r[Electron/([\d.]+)], 1] ||
        "0.0"
    end

    def match?
      ua =~ /Electron/
    end
  end
end
