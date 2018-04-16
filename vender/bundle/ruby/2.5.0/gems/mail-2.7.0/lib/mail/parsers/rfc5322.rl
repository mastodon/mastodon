%%{
  # RFC 5322 Internet Message Format
  # https://tools.ietf.org/html/rfc5322
  #
  # RFC 6854 Update to Internet Message Format to Allow Group Syntax in the "From:" and "Sender:" Header Fields
  # https://tools.ietf.org/html/rfc6854
  machine rfc5322;
  alphtype int;

  include rfc5234_abnf_core_rules "rfc5234_abnf_core_rules.rl";

  # 3.2. Lexical Tokens
  include rfc5322_lexical_tokens "rfc5322_lexical_tokens.rl";

  # 3.3. Date and Time Specification
  include rfc5322_date_time "rfc5322_date_time.rl";

  # 3.4. Address Specification
  include rfc5322_address "rfc5322_address.rl";

  # 3.5. Overall Message Syntax
  #rfc5322_text = 0x01..0x09 | "\v" | "\f" | 0x0e..0x1f;
  #text = rfc5322_text | utf8_non_ascii; # RFC6532 for UTF-8
  #obs_body = ((LF* CR* ((0x00 | text) LF* CR*)*) | CRLF)*
  #body = ((text{,998} CRLF)* text{,998}) | obs_body;
  #message = (fields | obs_fields) (CRLF body)?;


  # 3.6. Field Definitions

  # 3.6.4. Identification Fields
  obs_id_left = local_part;
  id_left = dot_atom_text | obs_id_left;
  # id_right modifications to support multiple '@' in msg_id.
  msg_id_atext = ALPHA | DIGIT | "!" | "#" | "$" | "%" | "&" | "'" | "*" |
                 "+" | "-" | "/" | "=" | "?" | "^" | "_" | "`" | "{" | "|" |
                 "}" | "~" | "@";
  msg_id_dot_atom_text = (msg_id_atext+ "."?)+;
  obs_id_right = domain;
  no_fold_literal = "[" (dtext)* "]";
  id_right = msg_id_dot_atom_text | no_fold_literal | obs_id_right;
  msg_id = (CFWS)?
           (("<" id_left "@" id_right ">") >msg_id_s %msg_id_e)
           (CFWS)?;
  message_ids = msg_id (CFWS? msg_id)*;


  # 3.6.7 Trace Fields
  # Added CFWS? to increase robustness (qmail likes to include a comment)
  received_token = word | angle_addr | addr_spec_no_angle_brackets | domain;
  received = ((CFWS? received_token*) >received_tokens_s %received_tokens_e)
              ";" date_time;

  # Envelope From
  ctime_date = day_name " "+ month " "+ day " " time_of_day " " year;
  null_sender = ('<>' ' '{0,1});
  envelope_from = (addr_spec_no_angle_brackets | null_sender) >address_s %address_e " "
                  (ctime_date >ctime_date_s %ctime_date_e);
}%%
