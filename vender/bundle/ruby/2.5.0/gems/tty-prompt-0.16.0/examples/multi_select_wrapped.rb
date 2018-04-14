# encoding: utf-8

require_relative '../lib/tty-prompt'

prompt = TTY::Prompt.new

quotes = [
  "There are certain queer times and occasions in this strange mixed affair we call life when a man takes this whole universe for a vast practical joke, though the wit thereof he but dimly discerns, and more than suspects that the joke is at nobody's expense but his own.",
  "Talk not to me of blasphemy, man; I'd strike the sun if it insulted me.",
  "There is a wisdom that is woe; but there is a woe that is madness. And there is a Catskill eagle in some souls that can alike dive down into the blackest gorges, and soar out of them again and become invisible in the sunny spaces. And even if he for ever flies within the gorge, that gorge is in the mountains; so that even in his lowest swoop the mountain eagle is still higher than other birds upon the plain, even though they soar."
]

answer = prompt.multi_select('Choose your quote?', quotes, echo: false)

puts "Answer: #{answer}"
