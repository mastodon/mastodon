module Colorize
  module InstanceMethods
    #
    # Change color of string
    #
    # Examples:
    #
    #   puts "This is blue".colorize(:blue)
    #   puts "This is light blue".colorize(:light_blue)
    #   puts "This is also blue".colorize(:color => :blue)
    #   puts "This is light blue with red background".colorize(:color => :light_blue, :background => :red)
    #   puts "This is light blue with red background".colorize(:light_blue ).colorize( :background => :red)
    #   puts "This is blue text on red".blue.on_red
    #   puts "This is red on blue".colorize(:red).on_blue
    #   puts "This is red on blue and underline".colorize(:red).on_blue.underline
    #   puts "This is blue text on red".blue.on_red.blink
    #   puts "This is uncolorized".blue.on_red.uncolorize
    #
    def colorize(params)
      return self if self.class.disable_colorization
      require_windows_libs
      scan_for_colors.inject(self.class.new) do |str, match|
        colors_from_params(match, params)
        defaults_colors(match)
        str << "\033[#{match[0]};#{match[1]};#{match[2]}m#{match[3]}\033[0m"
      end
    end

    #
    # Return uncolorized string
    #
    def uncolorize
      scan_for_colors.inject(self.class.new) do |str, match|
        str << match[3]
      end
    end

    #
    # Return true if string is colorized
    #
    def colorized?
      scan_for_colors.inject([]) do |colors, match|
        colors << match.tap(&:pop)
      end.flatten.compact.any?
    end

    private

    #
    # Set default colors
    #
    def defaults_colors(match)
      match[0] ||= mode(:default)
      match[1] ||= color(:default)
      match[2] ||= background_color(:default)
    end

    #
    # Set color from params
    #
    def colors_from_params(match, params)
      case params
      when Hash then colors_from_hash(match, params)
      when Symbol then color_from_symbol(match, params)
      end
    end

    #
    # Set colors from params hash
    #
    def colors_from_hash(match, hash)
      match[0] = mode(hash[:mode])                   if mode(hash[:mode])
      match[1] = color(hash[:color])                 if color(hash[:color])
      match[2] = background_color(hash[:background]) if background_color(hash[:background])
    end

    #
    # Set color from params symbol
    #
    def color_from_symbol(match, symbol)
      match[1] = color(symbol) if color(symbol)
    end

    #
    # Color for foreground (offset 30)
    #
    def color(color)
      self.class.color_codes[color] + 30 if self.class.color_codes[color]
    end

    #
    # Color for background (offset 40)
    #
    def background_color(color)
      self.class.color_codes[color] + 40 if self.class.color_codes[color]
    end

    #
    # Mode
    #
    def mode(mode)
      self.class.mode_codes[mode]
    end

    #
    # Scan for colorized string
    #
    def scan_for_colors
      scan(/\033\[([0-9;]+)m(.+?)\033\[0m|([^\033]+)/m).map do |match|
        split_colors(match)
      end
    end

    def split_colors(match)
      colors = (match[0] || '').split(';')
      array = Array.new(3)
      array[0], array[1], array[2] = colors if colors.length == 3
      array[1] = colors                     if colors.length == 1
      array[3] = match[1] || match[2]
      array
    end

    #
    # Require windows libs
    #
    def require_windows_libs
      require 'Win32/Console/ANSI' if RUBY_VERSION < '2.0.0' && RUBY_PLATFORM =~ /win32/
    rescue LoadError
      raise 'You must gem install win32console to use colorize on Windows'
    end
  end
end
