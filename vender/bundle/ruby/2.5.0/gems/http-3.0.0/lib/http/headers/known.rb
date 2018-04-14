# frozen_string_literal: true

module HTTP
  class Headers
    # Content-Types that are acceptable for the response.
    ACCEPT = "Accept"

    # The age the object has been in a proxy cache in seconds.
    AGE = "Age"

    # Authentication credentials for HTTP authentication.
    AUTHORIZATION = "Authorization"

    # Used to specify directives that must be obeyed by all caching mechanisms
    # along the request-response chain.
    CACHE_CONTROL = "Cache-Control"

    # An HTTP cookie previously sent by the server with Set-Cookie.
    COOKIE = "Cookie"

    # Control options for the current connection and list
    # of hop-by-hop request fields.
    CONNECTION = "Connection"

    # The length of the request body in octets (8-bit bytes).
    CONTENT_LENGTH = "Content-Length"

    # The MIME type of the body of the request
    # (used with POST and PUT requests).
    CONTENT_TYPE = "Content-Type"

    # The date and time that the message was sent (in "HTTP-date" format as
    # defined by RFC 7231 Date/Time Formats).
    DATE = "Date"

    # An identifier for a specific version of a resource,
    # often a message digest.
    ETAG = "ETag"

    # Gives the date/time after which the response is considered stale (in
    # "HTTP-date" format as defined by RFC 7231).
    EXPIRES = "Expires"

    # The domain name of the server (for virtual hosting), and the TCP port
    # number on which the server is listening. The port number may be omitted
    # if the port is the standard port for the service requested.
    HOST = "Host"

    # Allows a 304 Not Modified to be returned if content is unchanged.
    IF_MODIFIED_SINCE = "If-Modified-Since"

    # Allows a 304 Not Modified to be returned if content is unchanged.
    IF_NONE_MATCH = "If-None-Match"

    # The last modified date for the requested object (in "HTTP-date" format as
    # defined by RFC 7231).
    LAST_MODIFIED = "Last-Modified"

    # Used in redirection, or when a new resource has been created.
    LOCATION = "Location"

    # Authorization credentials for connecting to a proxy.
    PROXY_AUTHORIZATION = "Proxy-Authorization"

    # An HTTP cookie.
    SET_COOKIE = "Set-Cookie"

    # The form of encoding used to safely transfer the entity to the user.
    # Currently defined methods are: chunked, compress, deflate, gzip, identity.
    TRANSFER_ENCODING = "Transfer-Encoding"

    # Indicates what additional content codings have been applied to the
    # entity-body.
    CONTENT_ENCODING = "Content-Encoding"

    # The user agent string of the user agent.
    USER_AGENT = "User-Agent"

    # Tells downstream proxies how to match future request headers to decide
    # whether the cached response can be used rather than requesting a fresh
    # one from the origin server.
    VARY = "Vary"
  end
end
