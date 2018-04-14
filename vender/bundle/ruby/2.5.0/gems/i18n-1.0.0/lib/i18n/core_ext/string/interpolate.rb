# This file used to backport the Ruby 1.9 String interpolation syntax to Ruby 1.8.
#
# Since I18n has dropped support to Ruby 1.8, this file is not required anymore,
# however, Rails 3.2 still requires it directly:
#
# https://github.com/rails/rails/blob/3-2-stable/activesupport/lib/active_support/core_ext/string/interpolation.rb#L2
#
# So we can't just drop the file entirely, which would then break Rails users
# under Ruby 1.9. This file can be removed once Rails 3.2 support is dropped.
