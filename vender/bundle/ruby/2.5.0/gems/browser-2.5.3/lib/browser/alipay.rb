# frozen_string_literal: true

module Browser
  class Alipay < Base
    def id
      :alipay
    end

    def name
      "Alipay"
    end

    def full_version
      ua[%r[(?:AlipayClient)/([\d.]+)]i, 1] || "0.0"
    end

    def match?
      ua =~ /AlipayClient/i
    end
  end
end
