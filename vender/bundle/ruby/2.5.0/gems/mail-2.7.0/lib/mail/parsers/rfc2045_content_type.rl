%%{
  # RFC 2045 Section 5.1: Content-Type Header Field
  # https://tools.ietf.org/html/rfc2045#section-5.1
  # Previously: https://tools.ietf.org/html/rfc1049#section-3
  machine rfc2045_content_type;
  alphtype int;

  include rfc5322_lexical_tokens "rfc5322_lexical_tokens.rl";

  token = 0x21..0x27 | 0x2a..0x2b | 0x2c..0x2e | 0x30..0x39 | 0x41..0x5a | 0x5e..0x7e;
  value = (quoted_string | (token -- '"' | 0x3d)+) >param_val_s %param_val_e;
  attribute = (token+) >param_attr_s %param_attr_e;
  parameter = CFWS? attribute "=" value CFWS?;

  ietf_token = token+;
  custom_x_token = 'x'i "-" token+;
  extension_token = ietf_token | custom_x_token;
  discrete_type = 'text'i | 'image'i | 'audio'i | 'video'i |
                  'application'i | extension_token;
  composite_type = 'message'i | 'multipart'i | extension_token;
  iana_token = token+;
  main_type = (discrete_type | composite_type) >main_type_s %main_type_e;
  sub_type = (extension_token | iana_token) >sub_type_s %sub_type_e;
  content_type = main_type "/" sub_type (((CFWS? ";"+) | CFWS) parameter CFWS?)*;
}%%
