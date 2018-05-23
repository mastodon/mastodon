# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine envelope_from;
  alphtype int;

  # Address
  action address_s { address_s = p }
  action address_e { envelope_from.address = chars(data, address_s, p-1).rstrip }

  # ctime_date
  action ctime_date_s { ctime_date_s = p }
  action ctime_date_e { envelope_from.ctime_date = chars(data, ctime_date_s, p-1) }

  # No-op actions
  action angle_addr_s {}
  action comment_e {}
  action comment_s {}
  action domain_e {}
  action domain_s {}
  action local_dot_atom_e {}
  action local_dot_atom_pre_comment_e {}
  action local_dot_atom_pre_comment_s {}
  action local_dot_atom_s {}
  action phrase_s {}
  action phrase_e {}
  action qstr_e {}
  action qstr_s {}
  action date_s {}
  action date_e {}
  action time_s {}
  action time_e {}
  action local_quoted_string_s {}
  action local_quoted_string_e {}
  action obs_domain_list_s {}
  action obs_domain_list_e {}
  action group_name_s {}
  action group_name_e {}
  action msg_id_s {}
  action msg_id_e {}
  action received_tokens_s {}
  action received_tokens_e {}

  include rfc5322 "rfc5322.rl";
  main := envelope_from;
}%%

module Mail::Parsers
  module EnvelopeFromParser
    extend Mail::ParserTools

    EnvelopeFromStruct = Struct.new(:address, :ctime_date, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      envelope_from = EnvelopeFromStruct.new
      return envelope_from if Mail::Utilities.blank?(data)

      # Parser state
      address_s = ctime_date_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::EnvelopeFromElement, data, p)
      end

      envelope_from
    end
  end
end
