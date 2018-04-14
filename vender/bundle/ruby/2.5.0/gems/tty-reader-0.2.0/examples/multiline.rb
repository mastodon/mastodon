require_relative '../lib/tty-reader'

reader = TTY::Reader.new

answer = reader.read_multiline(">> ")

puts "\nanswer: #{answer}"
