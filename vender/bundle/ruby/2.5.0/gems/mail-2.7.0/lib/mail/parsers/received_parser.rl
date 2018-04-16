# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine date_time;
  alphtype int;

  # Received Tokens
  action received_tokens_s { received_tokens_s = p }
  action received_tokens_e { received.info = chars(data, received_tokens_s, p-1) }

  # Date
  action date_s { date_s = p }
  action date_e { received.date = chars(data, date_s, p-1).strip }

  # Time
  action time_s { time_s = p }
  action time_e { received.time = chars(data, time_s, p-1) }

  # No-op actions
  action address_s {}
  action address_e {}
  action angle_addr_s {}
  action ctime_date_s {}
  action ctime_date_e {}
  action comment_e {}
  action comment_s {}
  action phrase_s {}
  action phrase_e {}
  action domain_e {}
  action domain_s {}
  action local_dot_atom_e {}
  action local_dot_atom_pre_comment_e {}
  action local_dot_atom_pre_comment_s {}
  action local_dot_atom_s {}
  action qstr_e {}
  action qstr_s {}
  action local_quoted_string_s {}
  action local_quoted_string_e {}
  action obs_domain_list_s {}
  action obs_domain_list_e {}
  action group_name_s {}
  action group_name_e {}
  action msg_id_s {}
  action msg_id_e {}

  include rfc5322 "rfc5322.rl";
  main := received;
}%%

module Mail::Parsers
  module ReceivedParser
    extend Mail::ParserTools

    ReceivedStruct = Struct.new(:date, :time, :info, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      raise Mail::Field::NilParseError.new(Mail::ReceivedElement) if data.nil?

      # Parser state
      received = ReceivedStruct.new
      received_tokens_s = date_s = time_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::ReceivedElement, data, p)
      end

      received
    end
  end
end
