require 'mkmf'

$CFLAGS << ' -Wall -Wextra'

$srcs = %w[
  hamlit.c
  hescape.c
]

create_makefile('hamlit/hamlit')
