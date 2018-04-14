require_relative '../lib/tty-reader'

puts "*** TTY::Reader Shell ***"
puts "Press Ctrl-X to exit"

reader = TTY::Reader.new

reader.on(:keyctrl_x) { puts "Exiting..."; exit }

loop do
  reader.read_line('=> ')
end
