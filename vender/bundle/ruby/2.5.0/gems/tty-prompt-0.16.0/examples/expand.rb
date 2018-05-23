# encoding: utf-8

require_relative "../lib/tty-prompt"

choices = [{
  key: 'y',
  name: 'overwrite this file',
  value: :yes
}, {
  key: 'n',
  name: 'do not overwrite this file',
  value: :no
}, {
  key: 'a',
  name: 'overwrite this file and all later files',
  value: :all
}, {
  key: 'd',
  name: 'show diff',
  value: :diff
}, {
  key: 'q',
  name: 'quit; do not overwrite this file ',
  value: :quit
}]

prompt = TTY::Prompt.new

prompt.expand('Overwrite Gemfile?', choices, default: 3)
