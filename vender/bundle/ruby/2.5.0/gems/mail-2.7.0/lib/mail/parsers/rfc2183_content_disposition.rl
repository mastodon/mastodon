%%{
  # RFC 2183 The Content-Disposition Header Field
  # https://tools.ietf.org/html/rfc2183#section-2
  #
  # TODO: recognize filename, size, creation date, etc.
  machine rfc2183_content_disposition;
  alphtype int;

  include rfc2045_content_type "rfc2045_content_type.rl";

  disposition_type = 'inline'i | 'attachment'i | extension_token;
  disposition_parm = parameter;
  disposition = (disposition_type >disp_type_s %disp_type_e)
                (";" disposition_parm)*;
}%%
