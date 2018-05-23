%%{
  # RFC 5322 Internet Message Format
  # Section 3.2. Lexical Tokens
  # https://tools.ietf.org/html/rfc5322#section-3.2
  machine rfc5322_lexical_tokens;
  alphtype int;

  include rfc5234_abnf_core_rules "rfc5234_abnf_core_rules.rl";

  # 3.2.1.  Quoted characters
  obs_NO_WS_CTL = 0x01..0x08 | "\v" | "\f" | 0x0e..0x1f | 0x7f;
  obs_qp = "\\" (0x00 | obs_NO_WS_CTL | LF | CR);
  quoted_pair = ("\\" (VCHAR | WSP)) | obs_qp;

  # 3.2.2. Folding White Space and Comments
  obs_FWS = (CRLF? WSP)+;
  FWS = (WSP* CRLF WSP+) | (CRLF WSP+) | obs_FWS;

  obs_ctext = obs_NO_WS_CTL;
  rfc5322_ctext = 0x21..0x27 | 0x2a..0x5b | 0x5d..0x7e | obs_ctext;
  ctext = rfc5322_ctext | utf8_non_ascii; # RFC6532 for UTF-8

  # Recursive comments
  action comment_begin { fcall comment_tail; }
  action comment_exit { fret; }
  ccontent = ctext | quoted_pair | "(" @comment_begin;
  comment_tail := ((FWS? ccontent)* >comment_s) FWS? ")" @comment_exit;
  comment = "(" @comment_begin %comment_e;
  CFWS = ((FWS? comment)+ FWS?) | FWS;

  # 3.2.3. Atom
  rfc5322_atext = ALPHA | DIGIT | "!" | "#" | "$" | "%" | "&" |
                  "'" | "*" | "+" | "-" | "/" | "=" | "?" | "^" |
                  "_" | "`" | "{" | "|" | "}" | "~";
  atext = rfc5322_atext | utf8_non_ascii; # RFC6532 for UTF-8
  atom = CFWS? atext+ CFWS?;
  dot_atom_text = atext ("." atext)*;
  dot_atom = CFWS? dot_atom_text CFWS?;

  # 3.2.4. Quoted Strings
  obs_qtext = obs_NO_WS_CTL;
  rfc5322_qtext = 0x21 | 0x23..0x5b | 0x5d..0x7e | obs_qtext;
  qtext = rfc5322_qtext | utf8_non_ascii; # RFC6532 for UTF-8

  qcontent = qtext | quoted_pair;
  quoted_string = CFWS?
                  (DQUOTE
                    (((FWS? qcontent)* FWS?) >qstr_s %qstr_e)
                  DQUOTE)
                  CFWS?;

  # 3.2.5. Miscellaneous Tokens
  word = atom | quoted_string;

  obs_phrase = (word | "." | "@")+;
  phrase = (obs_phrase | word+) >phrase_s %phrase_e;

  # Not part of RFC, used for keywords per 3.6.5 Information Fields
  phrase_lists = phrase ("," FWS* phrase)*;
}%%
