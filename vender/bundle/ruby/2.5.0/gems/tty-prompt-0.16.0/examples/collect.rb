# encoding: utf-8

require 'json'

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new(prefix: '[?] ')

result = prompt.collect do
  key(:name).ask('Name?')

  key(:age).ask('Age?', convert: :int)

  key(:address) do
    key(:street).ask('Street?', required: true)
    key(:city).ask('City?')
    key(:zip).ask('Zip?', validate: /\A\d{3}\Z/)
  end
end

puts JSON.pretty_generate(result)
