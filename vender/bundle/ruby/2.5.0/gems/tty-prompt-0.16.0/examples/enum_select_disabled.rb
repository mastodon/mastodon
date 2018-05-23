# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

choices = [
  "Atom",
  {name: "Emacs", disabled: '(not installed)'},
  "GNU nano",
  {name: "Notepad++", disabled: '(not installed)'},
  "Sublime",
  "Vim"
]

prompt.enum_select('Select an editor', choices)
