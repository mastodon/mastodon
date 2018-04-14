%%{
  # RFC 2045 Section 6.1: Content-Transfer-Encoding Header Field
  # https://tools.ietf.org/html/rfc2045#section-6.1
  machine rfc2045_content_transfer_encoding;
  alphtype int;

  include rfc2045_content_type "rfc2045_content_type.rl";

  encoding = ('7bits' | '8bits' | '7bit' | '8bit' | 'binary' |
              'quoted-printable' | 'base64' | ietf_token |
              custom_x_token) >encoding_s %encoding_e;
  content_transfer_encoding = CFWS? encoding CFWS? ";"? CFWS?;
}%%
