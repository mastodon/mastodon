# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine content_transfer_encoding;
  alphtype int;

  action encoding_s { encoding_s = p }
  action encoding_e { content_transfer_encoding.encoding = chars(data, encoding_s, p-1).downcase }

  # No-op actions
  action comment_e { }
  action comment_s { }
  action phrase_e { }
  action phrase_s { }
  action qstr_e { }
  action qstr_s { }
  action param_attr_e { }
  action param_attr_s { }
  action param_val_e { }
  action param_val_s { }
  action main_type_e { }
  action main_type_s { }
  action sub_type_e { }
  action sub_type_s { }

  include rfc2045_content_transfer_encoding "rfc2045_content_transfer_encoding.rl";
  main := content_transfer_encoding;
}%%

module Mail::Parsers
  module ContentTransferEncodingParser
    extend Mail::ParserTools

    ContentTransferEncodingStruct = Struct.new(:encoding, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      content_transfer_encoding = ContentTransferEncodingStruct.new('')
      return content_transfer_encoding if Mail::Utilities.blank?(data)

      # Parser state
      encoding_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::ContentTransferEncodingElement, data, p)
      end

      content_transfer_encoding
    end
  end
end
