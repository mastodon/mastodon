# encoding: utf-8

module TTY
  module Color
    class Mode
      TERM_256 = /iTerm.app/x

      TERM_64 = /^(hpterm-color|wy370|wy370-105k|wy370-EPC|wy370-nk|
                 wy370-rv|wy370-tek|wy370-vb|wy370-w|wy370-wvb)$/x

      TERM_52 = /^(dg+ccc|dgunix+ccc|d430.*?[\-\+](dg|unix).*?[\-\+]ccc)$/x

      TERM_16 = /^(amiga-vnc|d430-dg|d430-unix|d430-unix-25|d430-unix-s|
                 d430-unix-sr|d430-unix-w|d430c-dg|d430c-unix|d430c-unix-25|
                 d430c-unix-s|d430c-unix-sr|d430c-unix-w|d470|d470-7b|d470-dg|
                 d470c|d470c-7b|d470c-dg|dg+color|dg\+fixed|dgunix\+fixed|
                 dgmode\+color|hp\+color|ncr260wy325pp|ncr260wy325wpp|
                 ncr260wy350pp|ncr260wy350wpp|nsterm|nsterm-c|nsterm-c-acs|
                 nsterm-c-s|nsterm-c-s-7|nsterm-c-s-acs|nsterm\+c|
                 nsterm-7-c|nsterm-bce)$/x

      TERM_8 = /vt100|xnuppc|wy350/x

      def initialize(env)
        @env = env
      end

      # Detect supported colors
      #
      # @return [Integer]
      #   out of 0, 8, 16, 52, 64, 256
      #
      # @api public
      def mode
        return 0 unless TTY::Color.tty?

        value = 8
        %w(from_term from_tput).each do |from_check|
          break if (value = public_send(from_check)) != NoValue
        end
        return 8 if value == NoValue
        value
      end

      # Check TERM environment for colors
      #
      # @return [NoValue, Integer]
      #
      # @api private
      def from_term
        case @env['TERM']
        when /[\-\+](\d+)color/ then $1.to_i
        when /[\-\+](\d+)bit/   then 2 ** $1.to_i
        when TERM_256 then 256
        when TERM_64  then 64
        when TERM_52  then 52
        when TERM_16  then 16
        when TERM_8   then 8
        when /dummy/  then 0
        else NoValue
        end
      end

      # Shell out to tput to check color support
      #
      # @return [NoValue, Integer]
      #
      # @api private
      def from_tput
        if !TTY::Color.command?("tput colors")
          return NoValue
        end
        colors = `tput colors 2>/dev/null`.to_i
        colors >= 8 ? colors : NoValue
      rescue Errno::ENOENT
        NoValue
      end
    end # Mode
  end # Color
end # TTY
