module OEmbed
  module Formatter
    # These are methods that are shared by the OEmbed::Formatter sub-classes
    # (i.e. OEmbed::Formatter:JSON and OEmbed::Formatter::XML).
    module Base

      # Returns true if there is a valid backend. Otherwise, raises OEmbed::FormatNotSupported
      def supported?
        !!backend
      end

      # Parses a String or IO and convert it into an Object
      def decode(value)
        backend.decode(value)
      end

      # Given either a String (the name of the backend to use) or an Object (which
      # must respond to the decode method), sets the current backend. Raises a LoadError
      # if the given backend cannot be loaded (e.g. an invalid String name, or the
      # decode method doesn't work properly).
      #   OEmbed::Formatter::XML.backend = 'REXML'
      #   OEmbed::Formatter::JSON.backend = MyCustomJsonDecoder.new
      def backend=(new_backend)
        new_backend_obj = case new_backend
        when String
          unless already_loaded?(new_backend)
            load "oembed/formatter/#{backend_path}/#{new_backend.downcase}.rb"
          end
          self::Backends.const_get(new_backend)
        else
          new_backend
        end

        test_backend(new_backend_obj)

        @backend = new_backend_obj

      rescue
        raise LoadError, "There was an error setting the backend: #{new_backend.inspect} - #{$!.message}"
      end

      # Perform a set of operations using a backend other than the current one.
      #   OEmbed::Formatter::XML.with_backend('XmlSimple') do
      #     OEmbed::Formatter::XML.decode(xml_value)
      #   end
      def with_backend(new_backend)
        old_backend, self.backend = backend, new_backend
        yield
      ensure
        self.backend = old_backend
      end

      private

      # Makes sure the given backend can correctly parse values using the decode
      # method.
      def test_backend(new_backend)
        raise LoadError, "The given backend must respond to the decode method: #{new_backend.inspect}" unless new_backend.respond_to?(:decode)

        expected = {
          "version"=>1.0,
          "string"=>"test",
          "int"=>42,
          "html"=>"<i>Cool's</i>\n the \"word\"!",
        }

        actual = new_backend.decode(test_value)

        # For the test to be true the actual output Hash should have the
        # exact same list of keys _and_ the values should be the same
        # if we ignoring typecasting.
        if(
          actual.keys.sort != expected.keys.sort ||
          actual.detect { |key, value| value.to_s != expected[key].to_s }
        )
          msg = new_backend.decode_fail_msg rescue nil
          msg ||= "The given backend failed to decode the test string correctly"
          raise LoadError, "#{msg}: #{new_backend.inspect}"
        end
      end

      def already_loaded?(new_backend)
        begin
          self::Backends.const_defined?(new_backend, false)
        rescue ArgumentError # we're dealing with ruby < 1.9 where const_defined? only takes 1 argument, but behaves the way we want it to.
          self::Backends.const_defined?(new_backend)
        rescue NameError # no backends have been loaded yet
          false
        end
      end

      # Must return a String representing the sub-directory where in-library
      # backend rb files live (e.g. 'json/backends')
      def backend_path
        raise "This method must be defined by a format-specific OEmbed::Formatter sub-class."
      end

      # Must return a String that when parsed by a backend returns the following ruby Hash
      #   {
      #     "version"=>1.0,
      #     "string"=>"test",
      #     "int"=>42,
      #     "html"=>"<i>Cool's</i>\n the \"word\"!",
      #   }
      def test_value
        raise "This method must be defined by a format-specific OEmbed::Formatter sub-class."
      end

    end # SharedMethods
  end
end