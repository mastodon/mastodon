# encoding: utf-8

module Pastel
  # Mixin that provides ANSI codes
  module ANSI
    ATTRIBUTES = {
      clear:      0,
      reset:      0,
      bold:       1,
      dark:       2,
      dim:        2,
      italic:     3,
      underline:  4,
      underscore: 4,
      inverse:    7,
      hidden:     8,
      strikethrough: 9,

      black:   30,
      red:     31,
      green:   32,
      yellow:  33,
      blue:    34,
      magenta: 35,
      cyan:    36,
      white:   37,

      on_black:   40,
      on_red:     41,
      on_green:   42,
      on_yellow:  43,
      on_blue:    44,
      on_magenta: 45,
      on_cyan:    46,
      on_white:   47,

      bright_black:   90,
      bright_red:     91,
      bright_green:   92,
      bright_yellow:  93,
      bright_blue:    94,
      bright_magenta: 95,
      bright_cyan:    96,
      bright_white:   97,

      on_bright_black:   100,
      on_bright_red:     101,
      on_bright_green:   102,
      on_bright_yellow:  103,
      on_bright_blue:    104,
      on_bright_magenta: 105,
      on_bright_cyan:    106,
      on_bright_white:   107
    }.freeze

    module_function

    def foreground?(code)
      [*(30..37), *(90..97)].include?(code.to_i)
    end

    def background?(code)
      [*(40..47), *(100..107)].include?(code.to_i)
    end

    def style?(code)
      (1..9).include?(code.to_i)
    end
  end # ANSI
end # Pastel
