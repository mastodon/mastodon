# frozen_string_literal: true

module Browser
  class Otter < Base
    def id
      :otter
    end

    def name
      "Otter"
    end

    def full_version
      ua[%r[Otter/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /Otter/
    end
  end
end
