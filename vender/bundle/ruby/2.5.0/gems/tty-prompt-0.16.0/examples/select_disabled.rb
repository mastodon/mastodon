# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

warriors = [
  'Scorpion',
  'Kano',
  { name: 'Goro', disabled: '(injury)' },
  'Jax',
  'Kitana',
  'Raiden'
]

answer = prompt.select('Choose your destiny?', warriors, enum: ')')

puts answer.inspect
