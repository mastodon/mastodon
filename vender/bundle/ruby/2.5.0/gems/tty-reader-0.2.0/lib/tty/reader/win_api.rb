# encoding: utf-8
# frozen_string_literal: true

require 'fiddle'

module TTY
  class Reader
    module WinAPI
      include Fiddle

      Handle = RUBY_VERSION >= "2.0.0" ? Fiddle::Handle : DL::Handle

      CRT_HANDLE = Handle.new("msvcrt") rescue Handle.new("crtdll")

      # Get a character from the console without echo.
      #
      # @return [String]
      #   return the character read
      #
      # @api public
      def getch
        @@getch ||= Fiddle::Function.new(CRT_HANDLE["_getch"], [], TYPE_INT)
        @@getch.call
      end
      module_function :getch

      # Gets a character from the console with echo.
      #
      # @return [String]
      #   return the character read
      #
      # @api public
      def getche
        @@getche ||= Fiddle::Function.new(CRT_HANDLE["_getche"], [], TYPE_INT)
        @@getche.call
      end
      module_function :getche

      # Check the console for recent keystroke. If the function
      # returns a nonzero value, a keystroke is waiting in the buffer.
      #
      # @return [Integer]
      #   return a nonzero value if a key has been pressed. Otherwirse,
      #   it returns 0.
      #
      # @api public
      def kbhit
        @@kbhit ||= Fiddle::Function.new(CRT_HANDLE["_kbhit"], [], TYPE_INT)
        @@kbhit.call
      end
      module_function :kbhit
    end # WinAPI
  end # Reader
end # TTY
