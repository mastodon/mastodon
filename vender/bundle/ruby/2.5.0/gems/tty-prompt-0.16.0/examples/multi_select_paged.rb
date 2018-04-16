# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

alfabet = ('A'..'Z').to_a

prompt.multi_select('Which letter?', alfabet, per_page: 5)
