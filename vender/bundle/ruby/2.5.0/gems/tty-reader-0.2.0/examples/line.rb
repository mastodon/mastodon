require_relative '../lib/tty-reader'

reader = TTY::Reader.new

answer = reader.read_line(">> ")

puts "answer: #{answer}"
