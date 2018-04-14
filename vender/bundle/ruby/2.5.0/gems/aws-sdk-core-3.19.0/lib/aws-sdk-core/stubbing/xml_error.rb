module Aws
  module Stubbing
    class XmlError

      def initialize(error_code)
        @error_code = error_code
      end

      def to_xml
        <<-XML.strip
<ErrorResponse>
  <Error>
    <Code>#{@error_code}</Code>
    <Message>stubbed-response-error-message</Message>
  </Error>
</ErrorResponse>
        XML
      end

    end
  end
end
