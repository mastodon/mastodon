# Copyright (C) 2007, 2008, 2009, 2010 Christian Neukirchen <purl.org/net/chneukirchen>
#
# Rack is freely distributable under the terms of an MIT-style license.
# See COPYING or http://www.opensource.org/licenses/mit-license.php.

# The Rack main module, serving as a namespace for all core Rack
# modules and classes.
#
# All modules meant for use in your application are <tt>autoload</tt>ed here,
# so it should be enough just to <tt>require 'rack'</tt> in your code.

module Rack
  # The Rack protocol version number implemented.
  VERSION = [1,3]

  # Return the Rack protocol version as a dotted string.
  def self.version
    VERSION.join(".")
  end

  RELEASE = "2.0.4"

  # Return the Rack release as a dotted string.
  def self.release
    RELEASE
  end

  HTTP_HOST         = 'HTTP_HOST'.freeze
  HTTP_VERSION      = 'HTTP_VERSION'.freeze
  HTTPS             = 'HTTPS'.freeze
  PATH_INFO         = 'PATH_INFO'.freeze
  REQUEST_METHOD    = 'REQUEST_METHOD'.freeze
  REQUEST_PATH      = 'REQUEST_PATH'.freeze
  SCRIPT_NAME       = 'SCRIPT_NAME'.freeze
  QUERY_STRING      = 'QUERY_STRING'.freeze
  SERVER_PROTOCOL   = 'SERVER_PROTOCOL'.freeze
  SERVER_NAME       = 'SERVER_NAME'.freeze
  SERVER_ADDR       = 'SERVER_ADDR'.freeze
  SERVER_PORT       = 'SERVER_PORT'.freeze
  CACHE_CONTROL     = 'Cache-Control'.freeze
  CONTENT_LENGTH    = 'Content-Length'.freeze
  CONTENT_TYPE      = 'Content-Type'.freeze
  SET_COOKIE        = 'Set-Cookie'.freeze
  TRANSFER_ENCODING = 'Transfer-Encoding'.freeze
  HTTP_COOKIE       = 'HTTP_COOKIE'.freeze
  ETAG              = 'ETag'.freeze

  # HTTP method verbs
  GET     = 'GET'.freeze
  POST    = 'POST'.freeze
  PUT     = 'PUT'.freeze
  PATCH   = 'PATCH'.freeze
  DELETE  = 'DELETE'.freeze
  HEAD    = 'HEAD'.freeze
  OPTIONS = 'OPTIONS'.freeze
  LINK    = 'LINK'.freeze
  UNLINK  = 'UNLINK'.freeze
  TRACE   = 'TRACE'.freeze

  # Rack environment variables
  RACK_VERSION                        = 'rack.version'.freeze
  RACK_TEMPFILES                      = 'rack.tempfiles'.freeze
  RACK_ERRORS                         = 'rack.errors'.freeze
  RACK_LOGGER                         = 'rack.logger'.freeze
  RACK_INPUT                          = 'rack.input'.freeze
  RACK_SESSION                        = 'rack.session'.freeze
  RACK_SESSION_OPTIONS                = 'rack.session.options'.freeze
  RACK_SHOWSTATUS_DETAIL              = 'rack.showstatus.detail'.freeze
  RACK_MULTITHREAD                    = 'rack.multithread'.freeze
  RACK_MULTIPROCESS                   = 'rack.multiprocess'.freeze
  RACK_RUNONCE                        = 'rack.run_once'.freeze
  RACK_URL_SCHEME                     = 'rack.url_scheme'.freeze
  RACK_HIJACK                         = 'rack.hijack'.freeze
  RACK_IS_HIJACK                      = 'rack.hijack?'.freeze
  RACK_HIJACK_IO                      = 'rack.hijack_io'.freeze
  RACK_RECURSIVE_INCLUDE              = 'rack.recursive.include'.freeze
  RACK_MULTIPART_BUFFER_SIZE          = 'rack.multipart.buffer_size'.freeze
  RACK_MULTIPART_TEMPFILE_FACTORY     = 'rack.multipart.tempfile_factory'.freeze
  RACK_REQUEST_FORM_INPUT             = 'rack.request.form_input'.freeze
  RACK_REQUEST_FORM_HASH              = 'rack.request.form_hash'.freeze
  RACK_REQUEST_FORM_VARS              = 'rack.request.form_vars'.freeze
  RACK_REQUEST_COOKIE_HASH            = 'rack.request.cookie_hash'.freeze
  RACK_REQUEST_COOKIE_STRING          = 'rack.request.cookie_string'.freeze
  RACK_REQUEST_QUERY_HASH             = 'rack.request.query_hash'.freeze
  RACK_REQUEST_QUERY_STRING           = 'rack.request.query_string'.freeze
  RACK_METHODOVERRIDE_ORIGINAL_METHOD = 'rack.methodoverride.original_method'.freeze
  RACK_SESSION_UNPACKED_COOKIE_DATA   = 'rack.session.unpacked_cookie_data'.freeze

  autoload :Builder, "rack/builder"
  autoload :BodyProxy, "rack/body_proxy"
  autoload :Cascade, "rack/cascade"
  autoload :Chunked, "rack/chunked"
  autoload :CommonLogger, "rack/common_logger"
  autoload :ConditionalGet, "rack/conditional_get"
  autoload :Config, "rack/config"
  autoload :ContentLength, "rack/content_length"
  autoload :ContentType, "rack/content_type"
  autoload :ETag, "rack/etag"
  autoload :File, "rack/file"
  autoload :Deflater, "rack/deflater"
  autoload :Directory, "rack/directory"
  autoload :ForwardRequest, "rack/recursive"
  autoload :Handler, "rack/handler"
  autoload :Head, "rack/head"
  autoload :Lint, "rack/lint"
  autoload :Lock, "rack/lock"
  autoload :Logger, "rack/logger"
  autoload :MethodOverride, "rack/method_override"
  autoload :Mime, "rack/mime"
  autoload :NullLogger, "rack/null_logger"
  autoload :Recursive, "rack/recursive"
  autoload :Reloader, "rack/reloader"
  autoload :Runtime, "rack/runtime"
  autoload :Sendfile, "rack/sendfile"
  autoload :Server, "rack/server"
  autoload :ShowExceptions, "rack/show_exceptions"
  autoload :ShowStatus, "rack/show_status"
  autoload :Static, "rack/static"
  autoload :TempfileReaper, "rack/tempfile_reaper"
  autoload :URLMap, "rack/urlmap"
  autoload :Utils, "rack/utils"
  autoload :Multipart, "rack/multipart"

  autoload :MockRequest, "rack/mock"
  autoload :MockResponse, "rack/mock"

  autoload :Request, "rack/request"
  autoload :Response, "rack/response"

  module Auth
    autoload :Basic, "rack/auth/basic"
    autoload :AbstractRequest, "rack/auth/abstract/request"
    autoload :AbstractHandler, "rack/auth/abstract/handler"
    module Digest
      autoload :MD5, "rack/auth/digest/md5"
      autoload :Nonce, "rack/auth/digest/nonce"
      autoload :Params, "rack/auth/digest/params"
      autoload :Request, "rack/auth/digest/request"
    end
  end

  module Session
    autoload :Cookie, "rack/session/cookie"
    autoload :Pool, "rack/session/pool"
    autoload :Memcache, "rack/session/memcache"
  end
end
