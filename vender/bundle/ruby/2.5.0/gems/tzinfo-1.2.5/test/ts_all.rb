# Force a particular timezone to be local (helps find issues when local
# timezone isn't GMT). This won't work on Windows.
ENV['TZ'] = 'America/Los_Angeles'

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'tc_*.rb')].each {|t| require t}

puts "Using #{DataSource.get}"
