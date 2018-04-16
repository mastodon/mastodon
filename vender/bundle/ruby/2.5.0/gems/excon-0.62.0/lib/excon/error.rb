# frozen_string_literal: true
module Excon
  # Excon exception classes
  class Error < StandardError
    @default_status_error = :HTTPStatus

    class StubNotFound < Error; end
    class InvalidStub < Error; end

    # Socket related errors
    class Socket < Error
      attr_reader :socket_error

      def initialize(socket_error = Excon::Error.new)
        if is_a?(Certificate) || is_a?(Excon::Errors::CertificateError)
          super
        else
          super("#{socket_error.message} (#{socket_error.class})")
          set_backtrace(socket_error.backtrace)
          @socket_error = socket_error
        end
      end
    end

    # Certificate related errors
    class Certificate < Socket
      def initialize(socket_error = Excon::Error.new)
        msg = <<-EOL
Unable to verify certificate. This may be an issue with the remote host or with Excon. Excon has certificates bundled, but these can be customized:

            `Excon.defaults[:ssl_ca_path] = path_to_certs`
            `ENV['SSL_CERT_DIR'] = path_to_certs`
            `Excon.defaults[:ssl_ca_file] = path_to_file`
            `ENV['SSL_CERT_FILE'] = path_to_file`
            `Excon.defaults[:ssl_verify_callback] = callback`
                (see OpenSSL::SSL::SSLContext#verify_callback)
or:
            `Excon.defaults[:ssl_verify_peer] = false` (less secure).
        EOL
        full_message = "#{socket_error.message} (#{socket_error.class})" +
                       ' ' + msg
        super(full_message)
        set_backtrace(socket_error.backtrace)
        @socket_error = socket_error
      end
    end

    class Timeout < Error; end
    class ResponseParse < Error; end
    class ProxyParse < Error; end

    # Base class for HTTP Error classes
    class HTTPStatus < Error
      attr_reader :request, :response

      def initialize(msg, request = nil, response = nil)
        super(msg)
        @request = request
        @response = response
      end
    end

    # HTTP Error classes
    class Informational < HTTPStatus; end
    class Success < HTTPStatus; end
    class Redirection < HTTPStatus; end
    class Client < HTTPStatus; end
    class Server < HTTPStatus; end

    class Continue < Informational; end                  # 100
    class SwitchingProtocols < Informational; end        # 101
    class OK < Success; end                              # 200
    class Created < Success; end                         # 201
    class Accepted < Success; end                        # 202
    class NonAuthoritativeInformation < Success; end     # 203
    class NoContent < Success; end                       # 204
    class ResetContent < Success; end                    # 205
    class PartialContent < Success; end                  # 206
    class MultipleChoices < Redirection; end             # 300
    class MovedPermanently < Redirection; end            # 301
    class Found < Redirection; end                       # 302
    class SeeOther < Redirection; end                    # 303
    class NotModified < Redirection; end                 # 304
    class UseProxy < Redirection; end                    # 305
    class TemporaryRedirect < Redirection; end           # 307
    class BadRequest < Client; end                       # 400
    class Unauthorized < Client; end                     # 401
    class PaymentRequired < Client; end                  # 402
    class Forbidden < Client; end                        # 403
    class NotFound < Client; end                         # 404
    class MethodNotAllowed < Client; end                 # 405
    class NotAcceptable < Client; end                    # 406
    class ProxyAuthenticationRequired < Client; end      # 407
    class RequestTimeout < Client; end                   # 408
    class Conflict < Client; end                         # 409
    class Gone < Client; end                             # 410
    class LengthRequired < Client; end                   # 411
    class PreconditionFailed < Client; end               # 412
    class RequestEntityTooLarge < Client; end            # 413
    class RequestURITooLong < Client; end                # 414
    class UnsupportedMediaType < Client; end             # 415
    class RequestedRangeNotSatisfiable < Client; end     # 416
    class ExpectationFailed < Client; end                # 417
    class UnprocessableEntity < Client; end              # 422
    class TooManyRequests < Client; end                  # 429
    class InternalServerError < Server; end              # 500
    class NotImplemented < Server; end                   # 501
    class BadGateway < Server; end                       # 502
    class ServiceUnavailable < Server; end               # 503
    class GatewayTimeout < Server; end                   # 504

    def self.status_errors
      @status_errors ||= {
        100 => [Excon::Error::Continue, 'Continue'],
        101 => [Excon::Error::SwitchingProtocols, 'Switching Protocols'],
        200 => [Excon::Error::OK, 'OK'],
        201 => [Excon::Error::Created, 'Created'],
        202 => [Excon::Error::Accepted, 'Accepted'],
        203 => [Excon::Error::NonAuthoritativeInformation, 'Non-Authoritative Information'],
        204 => [Excon::Error::NoContent, 'No Content'],
        205 => [Excon::Error::ResetContent, 'Reset Content'],
        206 => [Excon::Error::PartialContent, 'Partial Content'],
        300 => [Excon::Error::MultipleChoices, 'Multiple Choices'],
        301 => [Excon::Error::MovedPermanently, 'Moved Permanently'],
        302 => [Excon::Error::Found, 'Found'],
        303 => [Excon::Error::SeeOther, 'See Other'],
        304 => [Excon::Error::NotModified, 'Not Modified'],
        305 => [Excon::Error::UseProxy, 'Use Proxy'],
        307 => [Excon::Error::TemporaryRedirect, 'Temporary Redirect'],
        400 => [Excon::Error::BadRequest, 'Bad Request'],
        401 => [Excon::Error::Unauthorized, 'Unauthorized'],
        402 => [Excon::Error::PaymentRequired, 'Payment Required'],
        403 => [Excon::Error::Forbidden, 'Forbidden'],
        404 => [Excon::Error::NotFound, 'Not Found'],
        405 => [Excon::Error::MethodNotAllowed, 'Method Not Allowed'],
        406 => [Excon::Error::NotAcceptable, 'Not Acceptable'],
        407 => [Excon::Error::ProxyAuthenticationRequired, 'Proxy Authentication Required'],
        408 => [Excon::Error::RequestTimeout, 'Request Timeout'],
        409 => [Excon::Error::Conflict, 'Conflict'],
        410 => [Excon::Error::Gone, 'Gone'],
        411 => [Excon::Error::LengthRequired, 'Length Required'],
        412 => [Excon::Error::PreconditionFailed, 'Precondition Failed'],
        413 => [Excon::Error::RequestEntityTooLarge, 'Request Entity Too Large'],
        414 => [Excon::Error::RequestURITooLong, 'Request-URI Too Long'],
        415 => [Excon::Error::UnsupportedMediaType, 'Unsupported Media Type'],
        416 => [Excon::Error::RequestedRangeNotSatisfiable, 'Request Range Not Satisfiable'],
        417 => [Excon::Error::ExpectationFailed, 'Expectation Failed'],
        422 => [Excon::Error::UnprocessableEntity, 'Unprocessable Entity'],
        429 => [Excon::Error::TooManyRequests, 'Too Many Requests'],
        500 => [Excon::Error::InternalServerError, 'InternalServerError'],
        501 => [Excon::Error::NotImplemented, 'Not Implemented'],
        502 => [Excon::Error::BadGateway, 'Bad Gateway'],
        503 => [Excon::Error::ServiceUnavailable, 'Service Unavailable'],
        504 => [Excon::Error::GatewayTimeout, 'Gateway Timeout']
      }
    end

    # Messages for nicer exceptions, from rfc2616
    def self.status_error(request, response)
      error_class, error_message = status_errors[response[:status]]
      if error_class.nil?
        default_class = Excon::Error.const_get(@default_status_error)
        error_class, error_message = [default_class, 'Unknown']
      end
      message = StringIO.new
      str = "Expected(#{request[:expects].inspect}) <=>" +
            " Actual(#{response[:status]} #{error_message})"
      message.puts(str)
      if request[:debug_request]
        message.puts('excon.error.request')
        Excon::PrettyPrinter.pp(message, request)
      end

      if request[:debug_response]
        message.puts('excon.error.response')
        Excon::PrettyPrinter.pp(message, response.data)
      end
      message.rewind
      error_class.new(message.read, request, response)
    end
  end

  # Legacy
  module Errors
    Excon::Errors::Error = Excon::Error

    legacy_re = /
      \A
      Client
      |Server
      |Socket
      |Certificate
      |HTTPStatus
      |InternalServer
      \Z
    /x

    klasses = Excon::Error.constants.select do |c|
      Excon::Error.const_get(c).is_a? Class
    end

    klasses.each do |klass|
      class_name = klass.to_s
      unless class_name =~ /Error\Z/
        class_name = klass.to_s + 'Error' if class_name =~ legacy_re
      end
      Excon::Errors.const_set(class_name, Excon::Error.const_get(klass))
    end

    def self.status_error(request, response)
      Excon::Error.status_error(request, response)
    end
  end
end
