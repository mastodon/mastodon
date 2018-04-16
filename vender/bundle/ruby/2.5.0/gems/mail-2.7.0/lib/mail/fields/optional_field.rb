# encoding: utf-8
# frozen_string_literal: true
# 
#    The field names of any optional-field MUST NOT be identical to any
#    field name specified elsewhere in this standard.
# 
# optional-field  =       field-name ":" unstructured CRLF
require 'mail/fields/unstructured_field'

module Mail
  class OptionalField < UnstructuredField
    private
      def do_encode
        "#{wrapped_value}\r\n"
      end
  end
end
