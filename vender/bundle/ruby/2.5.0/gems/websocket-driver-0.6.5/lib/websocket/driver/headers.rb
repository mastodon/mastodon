module WebSocket
  class Driver

    class Headers
      ALLOWED_DUPLICATES = %w[set-cookie set-cookie2 warning www-authenticate]

      def initialize(received = {})
        @raw = received
        clear

        @received = {}
        @raw.each { |k,v| @received[HTTP.normalize_header(k)] = v }
      end

      def clear
        @sent  = Set.new
        @lines = []
      end

      def [](name)
        @received[HTTP.normalize_header(name)]
      end

      def []=(name, value)
        return if value.nil?
        key = HTTP.normalize_header(name)
        return unless @sent.add?(key) or ALLOWED_DUPLICATES.include?(key)
        @lines << "#{name.strip}: #{value.to_s.strip}\r\n"
      end

      def inspect
        @raw.inspect
      end

      def to_h
        @raw.dup
      end

      def to_s
        @lines.join('')
      end
    end

  end
end
