#
# this is all here in case this example is run from the examples directory
#
begin
  require 'hitimes'
rescue LoadError => le
  %w[ ext lib ].each do |p|
    path = File.expand_path( File.join( File.dirname( __FILE__ ), "..", p ) )
    if $:.include?( path ) then
      raise le
    end
    $: << path
  end
  retry
end

s = Hitimes::Stats.new
dir = ARGV.shift || Dir.pwd
Dir.entries( dir ).each do |entry|
  fs = File.stat( entry )
  if fs.file? then
    s.update( fs.size )
  end
end

Hitimes::Stats::STATS.each do |m|
  puts "#{m.rjust(6)} : #{s.send( m ) }"
end

puts s.to_hash.inspect

