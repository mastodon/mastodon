# frozen_string_literal: true

module Browser
  class Facebook < Base
    def id
      :facebook
    end

    def name
      "Facebook"
    end

    def full_version
      ua[%r[FBAV/([\d.]+)], 1]
    end

    def match?
      ua =~ /FBAV/
    end
  end
end
