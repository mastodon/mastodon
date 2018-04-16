# frozen_string_literal: true

require "delegate"

require "http/response/status/reasons"

module HTTP
  class Response
    class Status < ::Delegator
      class << self
        # Coerces given value to Status.
        #
        # @example
        #
        #   Status.coerce(:bad_request) # => Status.new(400)
        #   Status.coerce("400")        # => Status.new(400)
        #   Status.coerce(true)         # => raises HTTP::Error
        #
        # @raise [Error] if coercion is impossible
        # @param [Symbol, #to_i] object
        # @return [Status]
        def coerce(object)
          code = case
                 when object.is_a?(String)  then SYMBOL_CODES[symbolize object]
                 when object.is_a?(Symbol)  then SYMBOL_CODES[object]
                 when object.is_a?(Numeric) then object.to_i
                 end

          return new code if code

          raise Error, "Can't coerce #{object.class}(#{object}) to #{self}"
        end
        alias [] coerce

        private

        # Symbolizes given string
        #
        # @example
        #
        #   symbolize "Bad Request"           # => :bad_request
        #   symbolize "Request-URI Too Long"  # => :request_uri_too_long
        #   symbolize "I'm a Teapot"          # => :im_a_teapot
        #
        # @param [#to_s] str
        # @return [Symbol]
        def symbolize(str)
          str.to_s.downcase.tr("-", " ").gsub(/[^a-z ]/, "").gsub(/\s+/, "_").to_sym
        end
      end

      # Code to Symbol map
      #
      # @example Usage
      #
      #   SYMBOLS[400] # => :bad_request
      #   SYMBOLS[414] # => :request_uri_too_long
      #   SYMBOLS[418] # => :im_a_teapot
      #
      # @return [Hash<Fixnum => Symbol>]
      SYMBOLS = Hash[REASONS.map { |k, v| [k, symbolize(v)] }].freeze

      # Reversed {SYMBOLS} map.
      #
      # @example Usage
      #
      #   SYMBOL_CODES[:bad_request]           # => 400
      #   SYMBOL_CODES[:request_uri_too_long]  # => 414
      #   SYMBOL_CODES[:im_a_teapot]           # => 418
      #
      # @return [Hash<Symbol => Fixnum>]
      SYMBOL_CODES = Hash[SYMBOLS.map { |k, v| [v, k] }].freeze

      # @return [Fixnum] status code
      attr_reader :code

      # @see REASONS
      # @return [String, nil] status message
      def reason
        REASONS[code]
      end

      # @return [String] string representation of HTTP status
      def to_s
        "#{code} #{reason}".strip
      end

      # Check if status code is informational (1XX)
      # @return [Boolean]
      def informational?
        100 <= code && code < 200
      end

      # Check if status code is successful (2XX)
      # @return [Boolean]
      def success?
        200 <= code && code < 300
      end

      # Check if status code is redirection (3XX)
      # @return [Boolean]
      def redirect?
        300 <= code && code < 400
      end

      # Check if status code is client error (4XX)
      # @return [Boolean]
      def client_error?
        400 <= code && code < 500
      end

      # Check if status code is server error (5XX)
      # @return [Boolean]
      def server_error?
        500 <= code && code < 600
      end

      # Symbolized {#reason}
      #
      # @return [nil] unless code is well-known (see REASONS)
      # @return [Symbol]
      def to_sym
        SYMBOLS[code]
      end

      # Printable version of HTTP Status, surrounded by quote marks,
      # with special characters escaped.
      #
      # (see String#inspect)
      def inspect
        "#<#{self.class} #{self}>"
      end

      SYMBOLS.each do |code, symbol|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{symbol}?      # def bad_request?
            #{code} == code   #   400 == code
          end                 # end
        RUBY
      end

      def __setobj__(obj)
        raise TypeError, "Expected #{obj.inspect} to respond to #to_i" unless obj.respond_to? :to_i
        @code = obj.to_i
      end

      def __getobj__
        @code
      end
    end
  end
end
