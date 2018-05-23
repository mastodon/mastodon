require "mkmf"
$CFLAGS << ' -O3 '
$CFLAGS << ' -std=c99'

# ruby.h has some -Wpedantic fails in some cases
# (e.g. https://github.com/Shopify/bootsnap/issues/15)
unless ['0', '', nil].include?(ENV['BOOTSNAP_PEDANTIC'])
  $CFLAGS << ' -Wall'
  $CFLAGS << ' -Werror'
  $CFLAGS << ' -Wextra'
  $CFLAGS << ' -Wpedantic'

  $CFLAGS << ' -Wno-unused-parameter' # VALUE self has to be there but we don't care what it is.
  $CFLAGS << ' -Wno-keyword-macro' # hiding return
end

create_makefile("bootsnap/bootsnap")
