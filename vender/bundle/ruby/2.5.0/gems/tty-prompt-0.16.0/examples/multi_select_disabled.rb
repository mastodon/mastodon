# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

drinks = [
  {name: 'sake', disabled: '(out of stock)'},
  'vodka',
  {name: 'beer', disabled: '(out of stock)'},
  'wine',
  'whisky',
  'bourbon'
]
answer = prompt.multi_select('Choose your favourite drink?', drinks, default: 2)

puts answer.inspect
