%%{
  # RFC 2045 MIME
  # https://tools.ietf.org/html/rfc2045
  machine rfc2045_mime;
  alphtype int;

  include rfc5322_lexical_tokens "rfc5322_lexical_tokens.rl";

  # 4. MIME-Version Header Field
  # https://tools.ietf.org/html/rfc2045#section-4
  mime_version = CFWS?
            (DIGIT+ >major_digits_s %major_digits_e)
            comment? "." comment?
            (DIGIT+ >minor_digits_s %minor_digits_e)
            CFWS?;
}%%
