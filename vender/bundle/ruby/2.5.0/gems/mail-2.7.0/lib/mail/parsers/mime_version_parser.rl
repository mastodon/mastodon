# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine mime_version;
  alphtype int;

  # Major Digits
  action major_digits_s { major_digits_s = p }
  action major_digits_e { mime_version.major = chars(data, major_digits_s, p-1) }

  # Minor Digits
  action minor_digits_s { minor_digits_s = p }
  action minor_digits_e { mime_version.minor = chars(data, minor_digits_s, p-1) }

  # No-op actions
  action comment_s {}
  action comment_e {}
  action qstr_s {}
  action qstr_e {}
  action phrase_s {}
  action phrase_e {}

  include rfc2045_mime "rfc2045_mime.rl";
  main := mime_version;
}%%

module Mail::Parsers
  module MimeVersionParser
    extend Mail::ParserTools

    MimeVersionStruct = Struct.new(:major, :minor, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      return MimeVersionStruct.new('', nil) if Mail::Utilities.blank?(data)

      # Parser state
      mime_version = MimeVersionStruct.new
      major_digits_s = minor_digits_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::MimeVersionElement, data, p)
      end

      mime_version
    end
  end
end
