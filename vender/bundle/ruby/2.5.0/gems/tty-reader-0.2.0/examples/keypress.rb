require_relative '../lib/tty-reader'

reader = TTY::Reader.new

puts "Press a key (or Ctrl-X to exit)"

loop do
  print "=> "
  char = reader.read_keypress
  if ?\C-x == char
    puts "Exiting..."
    exit
  else
    puts "#{char.inspect} [#{char.ord}] (hex: #{char.ord.to_s(16)})"
  end
end
