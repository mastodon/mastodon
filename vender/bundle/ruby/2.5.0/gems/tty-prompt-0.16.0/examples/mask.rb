# encoding: utf-8

require_relative "../lib/tty-prompt"
require 'pastel'

prompt = TTY::Prompt.new
heart = prompt.decorate('❤ ', :magenta)

res = prompt.mask('What is your secret?', mask: heart) do |q|
  q.validate(/[a-z\ ]{5,15}/)
end

puts "Secret: \"#{res}\""
