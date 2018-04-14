# frozen_string_literal: true

module Browser
  class Opera < Base
    def id
      :opera
    end

    def name
      "Opera"
    end

    def full_version
      ua[%r[OPR/([\d.]+)], 1] || ua[%r[Version/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /(Opera|OPR\/)/
    end
  end
end
