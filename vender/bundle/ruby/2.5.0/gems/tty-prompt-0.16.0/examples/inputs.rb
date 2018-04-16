# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

prompt.ask('What is your name?', default: ENV['USER'])
prompt.yes?('Do you like Ruby?')
prompt.mask("What is your secret?")
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
