module Nokogiri
  module XML
    class Text < Nokogiri::XML::CharacterData
      def content=(string)
        self.native_content = string.to_s
      end
    end
  end
end
