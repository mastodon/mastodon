# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

prompt.yes?('Do you like Ruby?')
