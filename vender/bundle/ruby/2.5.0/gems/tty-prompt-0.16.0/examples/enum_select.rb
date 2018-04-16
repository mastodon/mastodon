# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new
choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
prompt.enum_select('Select an editor', choices, default: 2)
