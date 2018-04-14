# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  # RFC 2557 Content-Location
  # https://tools.ietf.org/html/rfc2557#section-4.1
  machine content_location;
  alphtype int;

  # Quoted String
  action qstr_s { qstr_s = p }
  action qstr_e { content_location.location = chars(data, qstr_s, p-1) }

  # Token String
  action token_string_s { token_string_s = p }
  action token_string_e { content_location.location = chars(data, token_string_s, p-1) }

  # No-op actions
  action comment_e { }
  action comment_s { }
  action phrase_e { }
  action phrase_s { }
  action main_type_e { }
  action main_type_s { }
  action sub_type_e { }
  action sub_type_s { }
  action param_attr_e { }
  action param_attr_s { }
  action param_val_e { }
  action param_val_s { }

  include rfc2045_content_type "rfc2045_content_type.rl";

  location = quoted_string | ((token | 0x3d)+ >token_string_s %token_string_e);
  main := CFWS? location CFWS?;
}%%

module Mail::Parsers
  module ContentLocationParser
    extend Mail::ParserTools

    ContentLocationStruct = Struct.new(:location, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      content_location = ContentLocationStruct.new(nil)
      return content_location if Mail::Utilities.blank?(data)

      # Parser state
      disp_type_s = param_attr_s = param_attr = qstr_s = qstr = param_val_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::ContentLocationElement, data, p)
      end

      content_location
    end
  end
end
