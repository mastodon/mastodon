# fronzen_string_literal: true

require_relative 'version'

module TTY
  # Used for detecting screen properties
  #
  # @api public
  module Screen
    # Helper to define private functions
    def self.private_module_function(name)
      module_function(name)
      private_class_method(name)
    end

    # Default terminal size
    #
    # @api public
    DEFAULT_SIZE = [27, 80].freeze

    @env = ENV
    @output = $stderr

    class << self
      attr_accessor :env

      # Specifies an output stream
      #
      # @api public
      attr_accessor :output
    end

    # Get terminal rows and columns
    #
    # @return [Array[Integer, Integer]]
    #   return rows & columns
    #
    # @api public
    def size
      size = size_from_java
      size ||= size_from_win_api
      size ||= size_from_ioctl
      size ||= size_from_io_console
      size ||= size_from_readline
      size ||= size_from_tput
      size ||= size_from_stty
      size ||= size_from_env
      size ||= size_from_ansicon
      size ||  DEFAULT_SIZE
    end
    module_function :size

    def width
      size[1]
    end
    module_function :width

    alias columns width
    alias cols width
    module_function :columns
    module_function :cols

    def height
      size[0]
    end
    module_function :height

    alias rows height
    alias lines height
    module_function :rows
    module_function :lines

    STDOUT_HANDLE = 0xFFFFFFF5

    # Determine terminal size with a Windows native API
    #
    # @return [nil, Array[Integer, Integer]]
    #
    # @api private
    def size_from_win_api(verbose: nil)
      require 'fiddle'

      kernel32 = Fiddle::Handle.new('kernel32')
      get_std_handle = Fiddle::Function.new(kernel32['GetStdHandle'],
                        [-Fiddle::TYPE_INT], Fiddle::TYPE_INT)
      get_console_buffer_info = Fiddle::Function.new(
        kernel32['GetConsoleScreenBufferInfo'],
        [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

      format        = 'SSSSSssssSS'
      buffer        = ([0] * format.size).pack(format)
      stdout_handle = get_std_handle.(STDOUT_HANDLE)

      get_console_buffer_info.(stdout_handle, buffer)
      _, _, _, _, _, left, top, right, bottom, = buffer.unpack(format)
      size = [bottom - top + 1, right - left + 1]
      return size if nonzero_column?(size[1] - 1)
    rescue LoadError
      warn 'no native fiddle module found' if verbose
    rescue Fiddle::DLError
      # non windows platform or no kernel32 lib
    end
    module_function :size_from_win_api

    # Determine terminal size on jruby using native Java libs
    #
    # @return [nil, Array[Integer, Integer]]
    #
    # @api private
    def size_from_java(verbose: nil)
      return unless jruby?
      require 'java'
      java_import 'jline.TerminalFactory'
      terminal = TerminalFactory.get
      size = [terminal.get_height, terminal.get_width]
      return size if nonzero_column?(size[1])
    rescue
      warn 'failed to import java terminal package' if verbose
    end
    module_function :size_from_java

    # Detect screen size by loading io/console lib
    #
    # On Windows io_console falls back to reading environment
    # variables. This means any user changes to the terminal
    # size won't be reflected in the runtime of the Ruby app.
    #
    # @return [nil, Array[Integer, Integer]]
    #
    # @api private
    def size_from_io_console(verbose: nil)
      return if jruby?
      require 'io/console'

      begin
        if @output.tty? && IO.method_defined?(:winsize)
          size = @output.winsize
          size if nonzero_column?(size[1])
        end
      rescue Errno::EOPNOTSUPP
        # no support for winsize on output
      end
    rescue LoadError
      warn 'no native io/console support or io-console gem' if verbose
    end
    module_function :size_from_io_console

    TIOCGWINSZ = 0x5413
    TIOCGWINSZ_PPC = 0x40087468

    # Read terminal size from Unix ioctl
    #
    # @return [nil, Array[Integer, Integer]]
    #
    # @api private
    def size_from_ioctl
      return if jruby?
      return unless @output.respond_to?(:ioctl)

      format = 'SSSS'
      buffer = ([0] * format.size).pack(format)
      if ioctl?(TIOCGWINSZ, buffer) || ioctl?(TIOCGWINSZ_PPC, buffer)
        rows, cols, = buffer.unpack(format)[0..1]
        return [rows, cols] if nonzero_column?(cols)
      end
    end
    module_function :size_from_ioctl

    # Check if ioctl can be called and the device is attached to terminal
    #
    # @api private
    def ioctl?(control, buf)
      @output.ioctl(control, buf) >= 0
    rescue SystemCallError
      false
    end
    module_function :ioctl?

    # Detect screen size using Readline
    #
    # @api private
    def size_from_readline
      if defined?(Readline) && Readline.respond_to?(:get_screen_size)
        size = Readline.get_screen_size
        size if nonzero_column?(size[1])
      end
    rescue NotImplementedError
    end
    module_function :size_from_readline

    # Detect terminal size from tput utility
    #
    # @api private
    def size_from_tput
      return unless @output.tty?
      lines = run_command('tput', 'lines').to_i
      cols  = run_command('tput', 'cols').to_i
      [lines, cols] if nonzero_column?(lines)
    rescue IOError, SystemCallError
    end
    module_function :size_from_tput

    # Detect terminal size from stty utility
    #
    # @api private
    def size_from_stty
      return unless @output.tty?
      out = run_command('stty', 'size')
      return unless out
      size = out.split.map(&:to_i)
      size if nonzero_column?(size[1])
    rescue IOError, SystemCallError
    end
    module_function :size_from_stty

    # Detect terminal size from environment
    #
    # After executing Ruby code if the user changes terminal
    # dimensions during code runtime, the code won't be notified,
    # and hence won't see the new dimensions reflected in its copy
    # of LINES and COLUMNS environment variables.
    #
    # @return [nil, Array[Integer, Integer]]
    #
    # @api private
    def size_from_env
      return unless @env['COLUMNS'] =~ /^\d+$/
      size = [(@env['LINES'] || @env['ROWS']).to_i, @env['COLUMNS'].to_i]
      size if nonzero_column?(size[1])
    end
    module_function :size_from_env

    # Detect terminal size from Windows ANSICON
    #
    # @api private
    def size_from_ansicon
      return unless @env['ANSICON'] =~ /\((.*)x(.*)\)/
      size = [$2, $1].map(&:to_i)
      size if nonzero_column?(size[1])
    end
    module_function :size_from_ansicon

    # Runs command silently capturing the output
    #
    # @api private
    def run_command(*args)
      require 'tempfile'
      out = Tempfile.new('tty-screen')
      result = system(*args, out: out.path, err: File::NULL)
      return if result.nil?
      out.rewind
      out.read
    ensure
      out.close if out
    end
    private_module_function :run_command

    # Check if number is non zero
    #
    # return [Boolean]
    #
    # @api private
    def nonzero_column?(column)
      column.to_i > 0
    end
    private_module_function :nonzero_column?

    def jruby?
      RbConfig::CONFIG['ruby_install_name'] == 'jruby'
    end
    private_module_function :jruby?
  end # Screen
end # TTY
