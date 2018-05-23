# frozen_string_literal: true

module Browser
  class PhantomJS < Base
    def id
      :phantom_js
    end

    def name
      "PhantomJS"
    end

    def full_version
      ua[%r[PhantomJS/([\d.]+)], 1] || "0.0"
    end

    def match?
      ua =~ /PhantomJS/
    end
  end
end
