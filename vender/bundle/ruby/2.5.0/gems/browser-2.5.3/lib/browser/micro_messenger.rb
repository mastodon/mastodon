# frozen_string_literal: true

module Browser
  class MicroMessenger < Base
    def id
      :micro_messenger
    end

    def name
      "MicroMessenger"
    end

    def full_version
      ua[%r[(?:MicroMessenger)/([\d.]+)]i, 1] || "0.0"
    end

    def match?
      ua =~ /MicroMessenger/i
    end
  end
end
