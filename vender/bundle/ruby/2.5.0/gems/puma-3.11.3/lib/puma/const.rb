#encoding: utf-8
module Puma
  class UnsupportedOption < RuntimeError
  end


  # Every standard HTTP code mapped to the appropriate message.  These are
  # used so frequently that they are placed directly in Puma for easy
  # access rather than Puma::Const itself.

  # Every standard HTTP code mapped to the appropriate message.
  # Generated with:
  # curl -s https://www.iana.org/assignments/http-status-codes/http-status-codes-1.csv | \
  #   ruby -ne 'm = /^(\d{3}),(?!Unassigned|\(Unused\))([^,]+)/.match($_) and \
  #             puts "#{m[1]} => \x27#{m[2].strip}\x27,"'
  HTTP_STATUS_CODES = {
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',
    208 => 'Already Reported',
    226 => 'IM Used',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    308 => 'Permanent Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Payload Too Large',
    414 => 'URI Too Long',
    415 => 'Unsupported Media Type',
    416 => 'Range Not Satisfiable',
    417 => 'Expectation Failed',
    418 => 'I\'m A Teapot',
    421 => 'Misdirected Request',
    422 => 'Unprocessable Entity',
    423 => 'Locked',
    424 => 'Failed Dependency',
    426 => 'Upgrade Required',
    428 => 'Precondition Required',
    429 => 'Too Many Requests',
    431 => 'Request Header Fields Too Large',
    451 => 'Unavailable For Legal Reasons',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',
    507 => 'Insufficient Storage',
    508 => 'Loop Detected',
    510 => 'Not Extended',
    511 => 'Network Authentication Required'
  }

  # For some HTTP status codes the client only expects headers.
  #

  STATUS_WITH_NO_ENTITY_BODY = {
    204 => true,
    205 => true,
    304 => true
  }

  # Frequently used constants when constructing requests or responses.  Many times
  # the constant just refers to a string with the same contents.  Using these constants
  # gave about a 3% to 10% performance improvement over using the strings directly.
  #
  # The constants are frozen because Hash#[]= when called with a String key dups
  # the String UNLESS the String is frozen. This saves us therefore 2 object
  # allocations when creating the env hash later.
  #
  # While Puma does try to emulate the CGI/1.2 protocol, it does not use the REMOTE_IDENT,
  # REMOTE_USER, or REMOTE_HOST parameters since those are either a security problem or
  # too taxing on performance.
  module Const

    PUMA_VERSION = VERSION = "3.11.3".freeze
    CODE_NAME = "Love Song".freeze
    PUMA_SERVER_STRING = ['puma', PUMA_VERSION, CODE_NAME].join(' ').freeze

    FAST_TRACK_KA_TIMEOUT = 0.2

    # The default number of seconds for another request within a persistent
    # session.
    PERSISTENT_TIMEOUT = 20

    # The default number of seconds to wait until we get the first data
    # for the request
    FIRST_DATA_TIMEOUT = 30

    # How long to wait when getting some write blocking on the socket when
    # sending data back
    WRITE_TIMEOUT = 10

    # The original URI requested by the client.
    REQUEST_URI= 'REQUEST_URI'.freeze
    REQUEST_PATH = 'REQUEST_PATH'.freeze
    QUERY_STRING = 'QUERY_STRING'.freeze

    PATH_INFO = 'PATH_INFO'.freeze

    PUMA_TMP_BASE = "puma".freeze

    # Indicate that we couldn't parse the request
    ERROR_400_RESPONSE = "HTTP/1.1 400 Bad Request\r\n\r\n".freeze

    # The standard empty 404 response for bad requests.  Use Error4040Handler for custom stuff.
    ERROR_404_RESPONSE = "HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: Puma #{PUMA_VERSION}\r\n\r\nNOT FOUND".freeze

    # The standard empty 408 response for requests that timed out.
    ERROR_408_RESPONSE = "HTTP/1.1 408 Request Timeout\r\nConnection: close\r\nServer: Puma #{PUMA_VERSION}\r\n\r\n".freeze

    CONTENT_LENGTH = "CONTENT_LENGTH".freeze

    # Indicate that there was an internal error, obviously.
    ERROR_500_RESPONSE = "HTTP/1.1 500 Internal Server Error\r\n\r\n".freeze

    # A common header for indicating the server is too busy.  Not used yet.
    ERROR_503_RESPONSE = "HTTP/1.1 503 Service Unavailable\r\n\r\nBUSY".freeze

    # The basic max request size we'll try to read.
    CHUNK_SIZE = 16 * 1024

    # This is the maximum header that is allowed before a client is booted.  The parser detects
    # this, but we'd also like to do this as well.
    MAX_HEADER = 1024 * (80 + 32)

    # Maximum request body size before it is moved out of memory and into a tempfile for reading.
    MAX_BODY = MAX_HEADER

    REQUEST_METHOD = "REQUEST_METHOD".freeze
    HEAD = "HEAD".freeze
    # ETag is based on the apache standard of hex mtime-size-inode (inode is 0 on win32)
    LINE_END = "\r\n".freeze
    REMOTE_ADDR = "REMOTE_ADDR".freeze
    HTTP_X_FORWARDED_FOR = "HTTP_X_FORWARDED_FOR".freeze

    SERVER_NAME = "SERVER_NAME".freeze
    SERVER_PORT = "SERVER_PORT".freeze
    HTTP_HOST = "HTTP_HOST".freeze
    PORT_80 = "80".freeze
    PORT_443 = "443".freeze
    LOCALHOST = "localhost".freeze
    LOCALHOST_IP = "127.0.0.1".freeze
    LOCALHOST_ADDR = "127.0.0.1:0".freeze

    SERVER_PROTOCOL = "SERVER_PROTOCOL".freeze
    HTTP_11 = "HTTP/1.1".freeze

    SERVER_SOFTWARE = "SERVER_SOFTWARE".freeze
    GATEWAY_INTERFACE = "GATEWAY_INTERFACE".freeze
    CGI_VER = "CGI/1.2".freeze

    STOP_COMMAND = "?".freeze
    HALT_COMMAND = "!".freeze
    RESTART_COMMAND = "R".freeze

    RACK_INPUT = "rack.input".freeze
    RACK_URL_SCHEME = "rack.url_scheme".freeze
    RACK_AFTER_REPLY = "rack.after_reply".freeze
    PUMA_SOCKET = "puma.socket".freeze
    PUMA_CONFIG = "puma.config".freeze
    PUMA_PEERCERT = "puma.peercert".freeze

    HTTP = "http".freeze
    HTTPS = "https".freeze

    HTTPS_KEY = "HTTPS".freeze

    HTTP_VERSION = "HTTP_VERSION".freeze
    HTTP_CONNECTION = "HTTP_CONNECTION".freeze
    HTTP_EXPECT = "HTTP_EXPECT".freeze
    CONTINUE = "100-continue".freeze

    HTTP_11_100 = "HTTP/1.1 100 Continue\r\n\r\n".freeze
    HTTP_11_200 = "HTTP/1.1 200 OK\r\n".freeze
    HTTP_10_200 = "HTTP/1.0 200 OK\r\n".freeze

    CLOSE = "close".freeze
    KEEP_ALIVE = "keep-alive".freeze

    CONTENT_LENGTH2 = "content-length".freeze
    CONTENT_LENGTH_S = "Content-Length: ".freeze
    TRANSFER_ENCODING = "transfer-encoding".freeze
    TRANSFER_ENCODING2 = "HTTP_TRANSFER_ENCODING".freeze

    CONNECTION_CLOSE = "Connection: close\r\n".freeze
    CONNECTION_KEEP_ALIVE = "Connection: Keep-Alive\r\n".freeze

    TRANSFER_ENCODING_CHUNKED = "Transfer-Encoding: chunked\r\n".freeze
    CLOSE_CHUNKED = "0\r\n\r\n".freeze

    CHUNKED = "chunked".freeze

    COLON = ": ".freeze

    NEWLINE = "\n".freeze

    HIJACK_P = "rack.hijack?".freeze
    HIJACK = "rack.hijack".freeze
    HIJACK_IO = "rack.hijack_io".freeze

    EARLY_HINTS = "rack.early_hints".freeze
  end
end
