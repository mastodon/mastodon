require_relative 'lib/pastel'

pastel = Pastel.new

puts pastel.bold('bold  ') + ' ' + pastel.dim('dim   ') + ' ' + pastel.italic('italic  ') + ' ' + pastel.underline('underline') + '  ' + pastel.inverse('inverse  ') + '  ' + pastel.strikethrough('strikethrough')

puts pastel.red('red   ') + ' ' + pastel.green('green   ')  + ' ' + pastel.yellow('yellow   ') + ' ' + pastel.blue('blue   ') + ' ' + pastel.magenta('magenta   ') + ' ' + pastel.cyan('cyan   ') + ' ' + pastel.white('white')

puts pastel.bright_red('red   ') + ' ' + pastel.bright_green('green   ')  + ' ' + pastel.bright_yellow('yellow   ') + ' ' + pastel.bright_blue('blue   ') + ' ' + pastel.bright_magenta('magenta   ') + ' ' + pastel.bright_cyan('cyan   ') + ' ' + pastel.bright_white('white')


puts pastel.on_red('on_red') + ' ' + pastel.on_green('on_green') + ' ' + pastel.on_yellow('on_yellow') + ' ' + pastel.on_blue('on_blue') + ' ' + pastel.on_magenta('on_magenta') + ' ' + pastel.on_cyan('on_cyan') + ' ' + pastel.on_white('on_white')

puts pastel.on_bright_red('on_red') + ' ' + pastel.on_bright_green('on_green') + ' ' + pastel.on_bright_yellow('on_yellow') + ' ' + pastel.on_bright_blue('on_blue') + ' ' + pastel.on_bright_magenta('on_magenta') + ' ' + pastel.on_bright_cyan('on_cyan') + ' ' + pastel.on_bright_white('on_white')
