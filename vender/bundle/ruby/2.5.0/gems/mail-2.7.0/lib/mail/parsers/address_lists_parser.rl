# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'

%%{
  machine address_lists;
  alphtype int;

  # Phrase
  action phrase_s { phrase_s = p }
  action phrase_e { phrase_e = p-1 }

  # Quoted String.
  action qstr_s { qstr_s = p }
  action qstr_e { qstr = chars(data, qstr_s, p-1) }

  # Comment
  action comment_s { comment_s = p unless comment_s }
  action comment_e {
    if address
      address.comments << chars(data, comment_s, p-2)
    end
    comment_s = nil
  }

  # Group Name
  action group_name_s { group_name_s = p }
  action group_name_e {
    if qstr
      group = qstr
      qstr = nil
    else
      group = chars(data, group_name_s, p-1)
      group_name_s = nil
    end
    address_list.group_names << group
    group_name = group

    # Start next address
    address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
    address_s = p
    address.group = group_name
  }

  # Address
  action address_s { address_s = p }

  # Ignore address end events without a start event.
  action address_e {
    if address_s
      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
        if address.domain
          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
        else
          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
        end
      end
      address.raw = chars(data, address_s, p-1)
      address_list.addresses << address if address

      # Start next address
      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
      address.group = group_name
      address_s = nil
    end
  }

  # Don't set the display name until the address has actually started. This
  # allows us to choose quoted_s version if it exists and always use the
  # 'full' phrase version.
  action angle_addr_s {
    if qstr
      address.display_name = Mail::Utilities.unescape(qstr)
      qstr = nil
    elsif phrase_e
      address.display_name = chars(data, phrase_s, phrase_e).strip
      phrase_e = phrase_s = nil
    end
  }

  # Domain
  action domain_s { domain_s = p }
  action domain_e {
    address.domain = chars(data, domain_s, p-1).rstrip if address
  }

  # Local
  action local_dot_atom_s { local_dot_atom_s = p }
  action local_dot_atom_e { local_dot_atom_e = p-1 }
  action local_dot_atom_pre_comment_e { local_dot_atom_pre_comment_e = p-1 }
  action local_quoted_string_e { address.local = '"' + qstr + '"' if address }

  # obs_domain_list
  action obs_domain_list_s { obs_domain_list_s = p }
  action obs_domain_list_e { address.obs_domain_list = chars(data, obs_domain_list_s, p-1) }

  # Junk actions
  action addr_spec { }
  action ctime_date_e { }
  action ctime_date_s { }
  action date_e { }
  action date_s { }
  action disp_type_e { }
  action disp_type_s { }
  action encoding_e { }
  action encoding_s { }
  action main_type_e { }
  action main_type_s { }
  action major_digits_e { }
  action major_digits_s { }
  action minor_digits_e { }
  action minor_digits_s { }
  action msg_id_e { }
  action msg_id_s { }
  action param_attr_e { }
  action param_attr_s { }
  action param_val_e { }
  action param_val_s { }
  action received_tokens_e { }
  action received_tokens_s { }
  action sub_type_e { }
  action sub_type_s { }
  action time_e { }
  action time_s { }
  action token_string_e { }
  action token_string_s { }

  include rfc5322 "rfc5322.rl";
  main := address_lists;
}%%

module Mail::Parsers
  module AddressListsParser
    extend Mail::ParserTools

    AddressListStruct = Struct.new(:addresses, :group_names, :error)
    AddressStruct = Struct.new(:raw, :domain, :comments, :local,
                             :obs_domain_list, :display_name, :group, :error)

    %%write data noprefix;

    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      address_list = AddressListStruct.new([], [])
      return address_list if Mail::Utilities.blank?(data)

      phrase_s = phrase_e = qstr_s = qstr = comment_s = nil
      group_name_s = domain_s = group_name = nil
      local_dot_atom_s = local_dot_atom_e = nil
      local_dot_atom_pre_comment_e = nil
      obs_domain_list_s = nil

      address_s = 0
      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      %%write init;
      %%write exec;

      if p != eof || cs < %%{ write first_final; }%%
        raise Mail::Field::IncompleteParseError.new(Mail::AddressList, data, p)
      end

      address_list
    end
  end
end
