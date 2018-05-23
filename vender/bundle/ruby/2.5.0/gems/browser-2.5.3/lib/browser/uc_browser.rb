# frozen_string_literal: true

module Browser
  class UCBrowser < Base
    def id
      :uc_browser
    end

    def name
      "UCBrowser"
    end

    def full_version
      ua[%r[UCBrowser/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /UCBrowser/
    end
  end
end
