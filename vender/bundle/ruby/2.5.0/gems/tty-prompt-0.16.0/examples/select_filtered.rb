# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

warriors = %w(Scorpion Kano Jax Kitana Raiden)

answer = prompt.select('Choose your destiny?', warriors, filter: true)

puts answer.inspect
