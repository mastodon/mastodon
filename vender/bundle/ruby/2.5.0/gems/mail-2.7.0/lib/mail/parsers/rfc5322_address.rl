%%{
  # RFC 5322 Internet Message Format
  # Section 3.4. Address Specification
  # https://tools.ietf.org/html/rfc5322#section-3.4
  machine rfc5322_address;
  alphtype int;

  include rfc5234_abnf_core_rules "rfc5234_abnf_core_rules.rl";
  include rfc5322_lexical_tokens "rfc5322_lexical_tokens.rl";

  # local_part:
  domain_text = (DQUOTE (FWS? qcontent)+ FWS? DQUOTE) | atext+;
  local_dot_atom_text = ("."* domain_text "."*)+;
  local_dot_atom = CFWS?
                   (local_dot_atom_text >local_dot_atom_s %local_dot_atom_pre_comment_e)
                   CFWS?;
  obs_local_part = word ("." word)*;
  local_part = (local_dot_atom >local_dot_atom_s %local_dot_atom_e |
                (quoted_string %local_quoted_string_e) |
                obs_local_part);

  # Treetop parser behavior was to ignore addresses missing '@' inside of angle
  # brackets. This construction preserves that behavior.
  local_part_no_capture = (local_dot_atom | quoted_string | obs_local_part);

  # domain:
  domain_dot_atom_text = "."* domain_text ("."* domain_text)*;
  obs_dtext = obs_NO_WS_CTL | quoted_pair;
  rfc5322_dtext = 0x21..0x5a | 0x5e..0x7e | obs_dtext;
  dtext = rfc5322_dtext | utf8_non_ascii; # RFC6532 for UTF-8
  domain_dot_atom = CFWS? domain_dot_atom_text (CFWS? >(comment_after_address,1));
  domain_literal = CFWS? "[" (FWS? dtext)* FWS? "]" CFWS?;
  obs_domain = atom ("." atom)*;
  domain = (domain_dot_atom | domain_literal | obs_domain) >domain_s %domain_e;

  # 3.4.1. Addr-Spec Specification

  # The %(end_addr,N) priority resolves uncertainty when whitespace
  # after an addr_spec could cause it to be interpreted as a
  # display name: "bar@example.com ,..."

  addr_spec_in_angle_brackets =
    (local_part "@" domain) %(end_addr,1) |
    local_part_no_capture   %(end_addr,0);

  addr_spec_no_angle_brackets =
    (local_part "@" domain) %(end_addr,1) |
    local_part              %(end_addr,0);

  # angle_addr:
  obs_domain_list = (CFWS | ",")* "@" domain ("," CFWS? ("@" domain)?)*;
  obs_route = (obs_domain_list ":") >obs_domain_list_s %obs_domain_list_e;
  obs_angle_addr = CFWS? "<" obs_route? addr_spec_in_angle_brackets ">" CFWS?;

  angle_addr = CFWS? ("<" >angle_addr_s) addr_spec_in_angle_brackets ">" CFWS? |
                obs_angle_addr;

  # 3.4. Address Specification
  display_name = phrase;
  name_addr = display_name? %(end_addr,2) angle_addr;
  mailbox = (name_addr | addr_spec_no_angle_brackets) >address_s %address_e;
  obs_mbox_list = (CFWS? ",")* mailbox ("," (mailbox | CFWS)?)*;
  mailbox_list = (mailbox (("," | ";") mailbox)*) | obs_mbox_list;
  obs_group_list = (CFWS? ",")+ CFWS?;
  group_list = mailbox_list | CFWS | obs_group_list;
  group = (display_name >group_name_s %group_name_e) ":"
            (group_list?) ";" CFWS?;
  address = group | mailbox;
  #obs_addr_list = (CFWS? ",")* address ("," (address | CFWS)?)*;
  address_lists = address? %(comment_after_address,0)
                  (FWS* ("," | ";") FWS* address?)*;
}%%
