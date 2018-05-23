# frozen_string_literal: true

module Browser
  class QQ < Base
    def id
      :qq
    end

    def name
      "QQ Browser"
    end

    def full_version
      ua[%r[(?:Mobile MQQBrowser)/([\d.]+)]i, 1] ||
        ua[%r[(?:QQBrowserLite)/([\d.]+)]i, 1] ||
        ua[%r[(?:QQBrowser)/([\d.]+)]i, 1] ||
        ua[%r[(?:QQ)/([\d.]+)]i, 1] ||
        "0.0"
    end

    def match?
      ua =~ /QQ/i
    end
  end
end
