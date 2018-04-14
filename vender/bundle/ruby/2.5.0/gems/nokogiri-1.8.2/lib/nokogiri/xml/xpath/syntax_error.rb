module Nokogiri
  module XML
    class XPath
      class SyntaxError < XML::SyntaxError
        def to_s
          [super.chomp, str1].compact.join(': ')
        end
      end
    end
  end
end
