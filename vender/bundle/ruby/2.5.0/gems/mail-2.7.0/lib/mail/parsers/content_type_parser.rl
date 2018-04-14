# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine content_type;
  alphtype int;

  # Main Type
  action main_type_s { main_type_s = p }
  action main_type_e { content_type.main_type = chars(data, main_type_s, p-1).downcase }

  # Sub Type
  action sub_type_s { sub_type_s = p }
  action sub_type_e { content_type.sub_type = chars(data, sub_type_s, p-1).downcase }

  # Parameter Attribute
  action param_attr_s { param_attr_s = p }
  action param_attr_e { param_attr = chars(data, param_attr_s, p-1) }

  # Quoted String
  action qstr_s { qstr_s = p }
  action qstr_e { qstr = chars(data, qstr_s, p-1) }

  # Parameter Value
  action param_val_s { param_val_s = p }
  action param_val_e {
    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
    end

    # Use quoted s value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_type.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  }

  # No-op actions
  action comment_e { }
  action comment_s { }
  action phrase_e { }
  action phrase_s { }

  include rfc2045_content_type "rfc2045_content_type.rl";
  main := content_type;
}%%

module Mail::Parsers
  module ContentTypeParser
    extend Mail::ParserTools

    ContentTypeStruct = Struct.new(:main_type, :sub_type, :parameters, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      return ContentTypeStruct.new('text', 'plain', []) if Mail::Utilities.blank?(data)
      content_type = ContentTypeStruct.new(nil, nil, [])

      # Parser state
      main_type_s = sub_type_s = param_attr_s = param_attr = nil
      qstr_s = qstr = param_val_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::ContentTypeElement, data, p)
      end

      content_type
    end
  end
end
