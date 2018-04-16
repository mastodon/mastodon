# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

prompt.ask('How do you like it on scale 1 - 10?', in: '1-10') do |q|
  q.messages[:range?] = "Sorry wrong one!"
end
