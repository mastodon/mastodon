require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils.rb')

# Use a zoneinfo directory containing files needed by the tests.
# The symlinks in this directory are set up in test_utils.rb.
TZInfo::DataSource.set(:zoneinfo, File.join(File.expand_path(File.dirname(__FILE__)), 'zoneinfo').untaint)

require File.join(File.expand_path(File.dirname(__FILE__)), 'ts_all.rb')
