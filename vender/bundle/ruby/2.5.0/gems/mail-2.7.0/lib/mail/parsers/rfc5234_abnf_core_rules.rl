%%{
  # RFC 5234 B.1. Core Rules
  # https://tools.ietf.org/html/rfc5234#appendix-B.1
  machine rfc5234_abnf_core_rules;
  alphtype int;

  include rfc3629_utf8 "rfc3629_utf8.rl";

  LF = "\n";
  CR = "\r";
  CRLF = "\r\n";
  SP = " ";
  HTAB = "\t";
  WSP = SP | HTAB;
  DQUOTE = '"';
  DIGIT = [0-9];
  ALPHA = [a-zA-Z];

  # RFC6532 extension for UTF-8 content
  rfc5234_VCHAR = 0x21..0x7e;
  VCHAR = rfc5234_VCHAR | utf8_non_ascii;
}%%
