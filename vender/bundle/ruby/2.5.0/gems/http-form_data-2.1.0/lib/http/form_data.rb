# frozen_string_literal: true

require "http/form_data/part"
require "http/form_data/file"
require "http/form_data/multipart"
require "http/form_data/urlencoded"
require "http/form_data/version"

# http gem namespace.
# @see https://github.com/httprb/http
module HTTP
  # Utility-belt to build form data request bodies.
  # Provides support for `application/x-www-form-urlencoded` and
  # `multipart/form-data` types.
  #
  # @example Usage
  #
  #   form = FormData.create({
  #     :username     => "ixti",
  #     :avatar_file  => FormData::File.new("/home/ixti/avatar.png")
  #   })
  #
  #   # Assuming socket is an open socket to some HTTP server
  #   socket << "POST /some-url HTTP/1.1\r\n"
  #   socket << "Host: example.com\r\n"
  #   socket << "Content-Type: #{form.content_type}\r\n"
  #   socket << "Content-Length: #{form.content_length}\r\n"
  #   socket << "\r\n"
  #   socket << form.to_s
  module FormData
    # CRLF
    CRLF = "\r\n"

    # Generic FormData error.
    class Error < StandardError; end

    class << self
      # FormData factory. Automatically selects best type depending on given
      # `data` Hash.
      #
      # @param [#to_h, Hash] data
      # @return [Multipart] if any of values is a {FormData::File}
      # @return [Urlencoded] otherwise
      def create(data)
        data  = ensure_hash data
        klass = multipart?(data) ? Multipart : Urlencoded

        klass.new data
      end

      # Coerce `obj` to Hash.
      #
      # @note Internal usage helper, to workaround lack of `#to_h` on Ruby < 2.1
      # @raise [Error] `obj` can't be coerced.
      # @return [Hash]
      def ensure_hash(obj)
        case
        when obj.nil?               then {}
        when obj.is_a?(Hash)        then obj
        when obj.respond_to?(:to_h) then obj.to_h
        else raise Error, "#{obj.inspect} is neither Hash nor responds to :to_h"
        end
      end

      private

      # Tells whenever data contains multipart data or not.
      #
      # @param [Hash] data
      # @return [Boolean]
      def multipart?(data)
        data.any? do |_, v|
          next true if v.is_a? FormData::Part
          v.respond_to?(:to_ary) && v.to_ary.any? { |e| e.is_a? FormData::Part }
        end
      end
    end
  end
end
