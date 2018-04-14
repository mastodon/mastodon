# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

drinks = %w(vodka beer wine whisky bourbon)
prompt.multi_select('Choose your favourite drink?', drinks, help: '(Use arrow keys and Enter to finish)')
