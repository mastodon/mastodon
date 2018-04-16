begin
  puts IO.read(File.join(File.dirname(__FILE__), 'README'))
rescue Exception => e
  puts "The following error ocurred while installing the plugin: #{e.message}"
end
