# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt::new(interrupt: :exit)

prompt.on(:keypress) do |event|
  puts "name: #{event.key.name}, value: #{event.value.dump}"
end

prompt.read_keypress
