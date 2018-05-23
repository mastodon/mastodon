require 'mkmf'

dir_config("puma_http11")

unless ENV["DISABLE_SSL"]
  dir_config("openssl")

  if %w'crypto libeay32'.find {|crypto| have_library(crypto, 'BIO_read')} and
      %w'ssl ssleay32'.find {|ssl| have_library(ssl, 'SSL_CTX_new')}

    have_header "openssl/bio.h"
  end
end

create_makefile("puma/puma_http11")
