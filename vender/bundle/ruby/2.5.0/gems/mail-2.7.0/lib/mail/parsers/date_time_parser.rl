# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine date_time;
  alphtype int;

  # Date
  action date_s { date_s = p }
  action date_e { date_time.date_string = chars(data, date_s, p-1) }

  # Time
  action time_s { time_s = p }
  action time_e { date_time.time_string = chars(data, time_s, p-1) }

  # No-op actions
  action comment_s {}
  action comment_e {}
  action phrase_s {}
  action phrase_e {}
  action qstr_s {}
  action qstr_e {}

  include rfc5322_date_time "rfc5322_date_time.rl";
  main := date_time;
}%%

module Mail::Parsers
  module DateTimeParser
    extend Mail::ParserTools

    DateTimeStruct = Struct.new(:date_string, :time_string, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      raise Mail::Field::NilParseError.new(Mail::DateTimeElement) if data.nil?

      date_time = DateTimeStruct.new([])

      # Parser state
      date_s = time_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::DateTimeElement, data, p)
      end

      date_time
    end
  end
end
