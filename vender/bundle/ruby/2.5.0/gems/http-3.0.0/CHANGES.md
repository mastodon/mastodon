## 3.0.0 (2017-10-01)

* Drop support of Ruby `2.0` and Ruby `2.1`.
  ([@ixti])

* [#410](https://github.com/httprb/http/pull/410)
  Infer `Host` header upon redirects.
  ([@janko-m])

* [#409](https://github.com/httprb/http/pull/409)
  Enables request body streaming on any IO object.
  ([@janko-m])

* [#413](https://github.com/httprb/http/issues/413),
  [#414](https://github.com/httprb/http/pull/414)
  Fix encoding of body chunks.
  ([@janko-m])

* [#368](https://github.com/httprb/http/pull/368),
  [#357](https://github.com/httprb/http/issues/357)
  Fix timeout issue.
  ([@HoneyryderChuck])


## 2.2.2 (2017-04-27)

* [#404](https://github.com/httprb/http/issues/404),
  [#405](https://github.com/httprb/http/pull/405)
  Make keepalive timeout configurable.
  ([@nestegg])


## 2.2.1 (2017-02-06)

* [#395](https://github.com/httprb/http/issues/395)
  Fix regression of API, that broke webmock integration.
  ([@ixti])


## 2.2.0 (2017-02-03)

* [#375](https://github.com/httprb/http/pull/375)
  Add support for automatic Gzip/Inflate
  ([@Bonias])

* [#390](https://github.com/httprb/http/pull/390)
  Add REPORT to the list of valid HTTP verbs
  ([@ixti])


## 2.1.0 (2016-11-08)

* [#370](https://github.com/httprb/http/issues/370)
  Add Headers#include?
  ([@ixti])

* [#364](https://github.com/httprb/http/issues/364)
  Add HTTP::Response#connection
  ([@janko-m])

* [#362](https://github.com/httprb/http/issues/362)
  connect_ssl uses connect_timeout (Closes #359)
  ([@TiagoCardoso1983])


## 2.0.3 (2016-08-03)

* [#365](https://github.com/httprb/http/issues/365)
  Add `HTTP::Response#content_length`
  ([@janko-m])

* [#335](https://github.com/httprb/http/issues/335),
  [#360](https://github.com/httprb/http/pull/360)
  Set `Content-Length: 0` header for `nil` bodies.
  ([@britishtea])


## 2.0.2 (2016-06-24)

* [#353](https://github.com/httprb/http/pull/353)
  Avoid a dependency cycle between Client and Connection classes.
  ([@jhbabon])


## 2.0.1 (2016-05-12)

* [#341](https://github.com/httprb/http/pull/341)
  Refactor some string manipulations so they are more performant
  (up to 3-4x faster) and more concise.
  ([@tonyta])

* [#339](https://github.com/httprb/http/pull/341)
  Always use byte methods when writing/slicing the write buffer.
  ([@zanker])


## 2.0.0 (2016-04-23)

* [#333](https://github.com/httprb/http/pull/333)
  Fix HTTPS request headline when sent via proxy.
  ([@Connorhd])

* [#331](https://github.com/httprb/http/pull/331)
  Add `#informational?`, `#success?`, `#redirect?`, `#client_error?` and
  `#server_error?` helpers to `Response::Status`.
  ([@mwitek])

* [#330](https://github.com/httprb/http/pull/330)
  Support custom CONNECT headers (request/response) during HTTPS proxy requests.
  ([@smudge])

* [#319](https://github.com/httprb/http/pull/319)
  Drop Ruby 1.9.x support.
  ([@ixti])


## 1.0.4 (2016-03-19)

* [#320](https://github.com/httprb/http/pull/320)
  Fix timeout regression.
  ([@tarcieri])


## 1.0.3 (2016-03-16)

* [#314](https://github.com/httprb/http/pull/314)
  Validate charset before forcing encoding.
  ([@kylekyle])

* [#318](https://github.com/httprb/http/pull/318)
  Remove redundant string allocations upon header names normalization.
  ([@ixti])


## 1.0.2 (2016-01-15)

* [#295](https://github.com/httprb/http/pull/295):
  Fix redirect following when used with persistent mode.
  ([@ixti])


## 1.0.1 (2015-12-27)

* [#283](https://github.com/httprb/http/pull/283):
  Use io/wait on supported platforms.
  ([@tarcieri])


## 1.0.0 (2015-12-25)

* [#265](https://github.com/httprb/http/pull/265/):
  Remove deprecations ([@tarcieri]):
  - HTTP::Chainable#with_follow (use #follow)
  - HTTP::Chainable#with, #with_headers (use #headers)
  - HTTP::Chainable#auth(:basic, ...) (use #basic_auth)
  - HTTP::Chainable#default_headers (use #default_options[:headers])
  - HTTP::Headers#append (use #add)
  - HTTP::Options#[] hash-like API deprecated in favor of explicit methods
  - HTTP::Request#request_header (use #headline)
  - HTTP::Response::STATUS_CODES (use HTTP::Status::REASONS)
  - HTTP::Response::SYMBOL_TO_STATUS_CODE (no replacement)
  - HTTP::Response#status_code (use #status or #code)
  - HTTP::Response::Status#symbolize (use #to_sym)

* [#269](https://github.com/httprb/http/pull/269/):
  Close connection in case of error during request.
  ([@ixti])

* [#271](https://github.com/httprb/http/pull/271/):
  High-level exception wrappers for low-level I/O errors.
  ([@ixti])

* [#273](https://github.com/httprb/http/pull/273/):
  Add encoding option.
  ([@connorhd])

* [#275](https://github.com/httprb/http/pull/275/):
  Support for disabling Nagle's algorithm with `HTTP.nodelay`.
  ([@nerdrew])

* [#276](https://github.com/httprb/http/pull/276)
  Use Encoding::BINARY as the default encoding for HTTP::Response::Body.
  ([@tarcieri])

* [#278](https://github.com/httprb/http/pull/278)
  Use an options hash for HTTP::Request initializer API.
  ([@ixti])

* [#279](https://github.com/httprb/http/pull/279)
  Send headers and body in one write if possible.
  This avoids a pathological case in Nagle's algorithm.
  ([@tarcieri])

* [#281](https://github.com/httprb/http/pull/281)
  Remove legacy 'Http' constant alias to 'HTTP'.
  ([@tarcieri])


## 0.9.9 (2016-03-16)

* *BACKPORT* [#318](https://github.com/httprb/http/pull/318)
  Remove redundant string allocations upon header names normalization.
  ([@ixti])

* *BACKPORT* [#295](https://github.com/httprb/http/pull/295):
  Fix redirect following when used with persistent mode.
  ([@ixti])


## 0.9.8 (2015-09-29)

* [#260](https://github.com/httprb/http/pull/260):
  Fixed global timeout persisting time left across requests when reusing connections.
  ([@zanker])


## 0.9.7 (2015-09-19)

* [#258](https://github.com/httprb/http/pull/258):
  Unified strategy for handling exception-based and exceptionless non-blocking
  I/O. Fixes SSL support on JRuby 9000. ([@tarcieri])


## 0.9.6 (2015-09-06)

* [#254](https://github.com/httprb/http/pull/254):
  Removed use of an ActiveSupport specific method #present?
  ([@tarcieri])


## 0.9.5 (2015-09-06)

* [#252](https://github.com/httprb/http/pull/252):
  Fixed infinite hang/timeout when a request contained more than ~16,363 bytes.
  ([@zanker])


## 0.9.4 (2015-08-26)

* [#246](https://github.com/httprb/http/issues/246):
  Fixes regression when body streaming was failing on some URIs.
  ([@zanker])
* [#243](https://github.com/httprb/http/issues/243):
  Fixes require timeout statements. ([@ixti])


## 0.9.3 (2015-08-19)

* [#246](https://github.com/httprb/http/issues/246):
  Fixed request URI normalization. ([@ixti])
  - Avoids query component normalization
  - Omits fragment component in headline


## 0.9.2 (2015-08-18)

* Fixed exceptionless NIO EOF handling. ([@zanker])


## 0.9.1 (2015-08-14)

* [#246](https://github.com/httprb/http/issues/246):
  Fix params special-chars escaping. ([@ixti])


## 0.9.0 (2015-07-23)

* [#240](https://github.com/httprb/http/pull/240):
  Support for caching removed. ([@tarcieri])
* JRuby 9000 compatibility


## 0.8.14 (2015-08-19)

* Backport request URI normalization fixes from master. ([@ixti])


## 0.8.13 (2015-08-14)

* Backport params special-chars escaping fix from `v0.9.1`. ([@ixti])


## 0.8.12 (2015-05-26)

* Fix `HTTP.timeout` API (was loosing previously defined options). ([@ixti])


## 0.8.11 (2015-05-22)

* [#229](https://github.com/httprb/http/pull/229):
  SNI support for HTTPS connections. ([@tarcieri])
* [#227](https://github.com/httprb/http/pull/227):
  Use "http.rb" in the User-Agent string. ([@tarcieri])


## 0.8.10 (2015-05-14)

* Fix cookie headers generation. ([@ixti])


## 0.8.9 (2015-05-11)

* Add cookies support. ([@ixti])
* [#219](https://github.com/httprb/http/pull/219):
  Enforce stringified body encoding. ([@Connorhd])


## 0.8.8 (2015-05-09)

* [#217](https://github.com/httprb/http/issues/217):
  Fix CONNECT header for proxies. ([@Connorhd])


## 0.8.7 (2015-05-08)

* Fix `HTTP.timeout` API with options only given. ([@ixti])


## 0.8.6 (2015-05-08)

* [#215](https://github.com/httprb/http/pull/215):
  Reset global timeouts after the request finishes. ([@zanker])


## 0.8.5 (2015-05-06)

* [#205](https://github.com/httprb/http/issues/205):
  Add simple timeouts configuration API. ([@ixti])
* Deprecate `Request#request_header`. Use `Request#headline` instead. ([@ixti])


## 0.8.4 (2015-04-23)

* Deprecate `#default_headers` and `#default_headers=`. ([@ixti])
* [#207](https://github.com/httprb/http/issues/207):
  Deprecate chainable methods with `with_` prefix. ([@ixti])
* [#186](https://github.com/httprb/http/pull/186):
  Add support of HTTPS connections through proxy. ([@Connorhd])


## 0.8.3 (2015-04-07)

* [#206](https://github.com/httprb/http/issues/206):
  Fix request headline. ([@ixti])
* Remove deprecated `Request#__method__`. ([@ixti])


## 0.8.2 (2015-04-06)

* [#203](https://github.com/httprb/http/issues/203):
  Fix Celluloid::IO compatibility. ([@ixti])
* Cleanup obsolete code. ([@zanker])


## 0.8.1 (2015-04-02)

* [#202](https://github.com/httprb/http/issues/202):
  Add missing `require "resolv"`. ([@ixti])
* [#200](https://github.com/httprb/http/issues/200),
  [#201](https://github.com/httprb/http/pull/201):
  Add block-form `#persistent` calls. ([@ixti])


## 0.8.0 (2015-04-01)

* [#199](https://github.com/httprb/http/pull/199):
  Properly handle WaitWritable for SSL. ([@zanker])
* [#197](https://github.com/httprb/http/pull/197):
  Add support for non-ASCII URis. ([@ixti])
* [#187](https://github.com/httprb/http/pull/187),
  [#194](https://github.com/httprb/http/pull/194),
  [#195](https://github.com/httprb/http/pull/195):
  Add configurable connection timeouts. ([@zanker])
* [#179](https://github.com/httprb/http/pull/179):
  Refactor requests redirect following logic. ([@ixti])
* Support for persistent HTTP connections ([@zanker])
* [#77](https://github.com/httprb/http/issues/77),
  [#177](https://github.com/httprb/http/pull/177):
  Add caching support. ([@Asmod4n], [@pezra])
* [#176](https://github.com/httprb/http/pull/176):
  Improve servers used in specs boot up. Issue was initially raised up
  by [@olegkovalenko]. ([@ixti])
* Reflect FormData rename changes (FormData -> HTTP::FormData). ([@ixti])
* [#173](https://github.com/httprb/http/pull/173):
  `HTTP::Headers` now raises `HTTP::InvalidHeaderNameError` in case of
  (surprise) invalid HTTP header field name (e.g.`"Foo:Bar"`). ([@ixti])


## 0.7.3 (2015-03-24)

* SECURITY FIX: http.rb failed to call the `#post_connection_check` method on
  SSL connections. This method implements hostname verification, and without it
  `http.rb` was vulnerable to MitM attacks. The problem was corrected by calling
  `#post_connection_check` (CVE-2015-1828) ([@zanker])


## 0.7.2 (2015-03-02)

* Swap from `form_data` to `http-form_data` (changed gem name).


## 0.7.1 (2015-01-03)

* Gemspec fixups
* Remove superfluous space in HTTP::Response inspection


## 0.7.0 (2015-01-02)

* [#73](https://github.com/httprb/http/issues/73),
  [#167](https://github.com/httprb/http/pull/167):
  Add support of multipart form data. ([@ixti])
* Fix URI path normalization: `https://github.com` -> `https://github.com/`.
  ([@ixti])
* [#163](https://github.com/httprb/http/pull/163),
  [#166](https://github.com/httprb/http/pull/166),
  [#152](https://github.com/httprb/http/issues/152):
  Fix handling of EOF which caused infinite loop. ([@mickm], [@ixti])
* Drop Ruby 1.8.7 support. ([@ixti])
* [#150](https://github.com/httprb/http/issues/150):
  Fix default Host header value. ([@ixti])
* Remove BearerToken authorization header. ([@ixti])
* `#auth` sugar now accepts only string value of Authorization header.
  Calling `#auth(:basic, opts)` is deprecated, use `#basic_auth(opts)` instead.
  ([@ixti])
* Fix handling of chunked responses without Content-Length header. ([@ixti])
* Remove `HTTP::Request#method` and deprecate `HTTP::Request#__method__`
  ([@sferik])
* Deprecate `HTTP::Response::STATUS_CODES`,
  use `HTTP::Response::Status::REASONS` instead ([@ixti])
* Deprecate `HTTP::Response::SYMBOL_TO_STATUS_CODE` ([@ixti])
* Deprecate `HTTP::Response#status_code` ([@ixti])
* `HTTP::Response#status` now returns `HTTP::Response::Status`. ([@ixti])
* `HTTP::Response#reason` and `HTTP::Response#code` are proxies them
  to corresponding methods of `HTTP::Response#status` ([@ixti])
* Rename `HTTP.with_follow` to `HTTP.follow` and mark former one as being
  deprecated ([@ixti])
* Delegate `HTTP::Response#readpartial` to `HTTP::Response::Body` ([@ixti])


## 0.6.4 (2015-03-25)

* SECURITY FIX: http.rb failed to call the `#post_connection_check` method on
  SSL connections. This method implements hostname verification, and without it
  `http.rb` was vulnerable to MitM attacks. The problem was corrected by calling
  `#post_connection_check` (CVE-2015-1828) ([@zanker], backported by [@nicoolas25])


## 0.6.3 (2014-11-14)

* [#166](https://github.com/httprb/http/pull/166):
  Backported EOF fix from master branch. ([@ixti])


## 0.6.2 (2014-08-06)

* [#150](https://github.com/httprb/http/issues/150):
  Fix default Host header value. ([@ixti])
* Deprecate BearerToken authorization header. ([@ixti])
* Fix handling of chunked responses without Content-Length header. ([@ixti])
* Rename `HTTP.with_follow` to `HTTP.follow` and mark former one as being
  deprecated ([@ixti])


## 0.6.1 (2014-05-07)

* Fix request `Content-Length` calculation for Unicode ([@challengee])
* Add `Response#flush` ([@ixti])
* Fix `Response::Body#readpartial` default size ([@hannesg], [@ixti])
* Add missing `CRLF` for chunked bodies ([@hannesg])
* Fix forgotten CGI require ([@ixti])
* Improve README ([@tarcieri])


## 0.6.0 (2014-04-04)

* Rename `HTTP::Request#method` to `HTTP::Request#verb` ([@krainboltgreene])
* Add `HTTP::ResponseBody` class ([@tarcieri])
* Change API of response on `HTTP::Client.request` and "friends" (`#get`, `#post`, etc) ([@tarcieri])
* Add `HTTP::Response#readpartial` ([@tarcieri])
* Add `HTTP::Headers` class ([@ixti])
* Fix and improve following redirects ([@ixti])
* Add `HTTP::Request#redirect` ([@ixti])
* Add `HTTP::Response#content_type` ([@ixti])
* Add `HTTP::Response#mime_type` ([@ixti])
* Add `HTTP::Response#charset` ([@ixti])
* Improve error message upon invalid URI scheme ([@ixti])
* Consolidate errors under common `HTTP::Error` namespace ([@ixti])
* Add easy way of adding Authorization header ([@ixti])
* Fix proxy support ([@hundredwatt])
* Fix and improve query params handing ([@jwinter])
* Change API of custom MIME type parsers ([@ixti])
* Remove `HTTP::Chainable#with_response` ([@ixti])
* Remove `HTTP::Response::BodyDelegator` ([@ixti])
* Remove `HTTP::Response#parsed_body` ([@ixti])
* Bump up input buffer from 4K to 16K ([@tarcieri])

``` ruby
# Main API change you will mention is that `request` method and it's
# syntax sugar helpers like `get`, `post`, etc. now returns Response
# object instead of BodyDelegator:

response = HTTP.get "http://example.com"
raw_body = HTTP.get("http://example.com").to_s
parsed_body = HTTP.get("http://example.com/users.json").parse

# Second major change in API is work with request/response headers
# It is now delegated to `HTTP::Headers` class, so you can check it's
# documentation for details, here we will only outline main difference.
# Duckface (`=`) does not appends headers anymore

request[:content_type] = "text/plain"
request[:content_type] = "text/html"
request[:content_type] # => "text/html"

# In order to add multiple header values, you should pass array:

request[:cookie] = ["foo=bar", "woo=hoo"]
request[:cookie] # => ["foo=bar", "woo=hoo"]

# or call `#add` on headers:

request.headers.add :accept, "text/plain"
request.headers.add :accept, "text/html"
request[:accept] # => ["text/plain", "text/html"]

# Also, you can now read body in chunks (stream):

res = HTTP.get "http://example.com"
File.open "/tmp/dummy.bin", "wb" do |io|
  while (chunk = res.readpartial)
    io << chunk
  end
end
```

[Changes discussion](https://github.com/httprb/http.rb/issues/116)


## 0.5.1 (2014-05-27)

* Backports redirector fixes from 0.6.0 ([@ixti])
* EOL of 0.5.X branch.


## 0.5.0 (2013-09-14)

* Add query string support
* New response delegator allows HTTP.get(uri).response
* HTTP::Chainable#stream provides a shorter alias for
  with_response(:object)
* Better string inspect for HTTP::Response
* Curb compatibility layer removed


## 0.4.0 (2012-10-12)

* Fix bug accessing https URLs
* Fix several instances of broken redirect handling
* Add default user agent
* Many additional minor bugfixes


## 0.3.0 (2012-09-01)

* New implementation based on tmm1's http_parser.rb instead of Net::HTTP
* Support for following redirects
* Support for request body through {:body => ...} option
* HTTP#with_response (through Chainable)


## 0.2.0 (2012-03-05)

* Request and response objects
* Callback system
* Internal refactoring ensuring true chainability
* Use the certified gem to ensure SSL certificate verification


## 0.1.0 (2012-01-26)

* Testing against WEBrick
* Curb compatibility (require 'http/compat/curb')


## 0.0.1 (2011-10-11)

* Initial half-baked release


## 0.0.0 (2011-10-06)

* Vapoware release to claim the "http" gem name >:D


[@tarcieri]: https://github.com/tarcieri
[@zanker]: https://github.com/zanker
[@ixti]: https://github.com/ixti
[@Connorhd]: https://github.com/Connorhd
[@Asmod4n]: https://github.com/Asmod4n
[@pezra]: https://github.com/pezra
[@olegkovalenko]: https://github.com/olegkovalenko
[@mickm]: https://github.com/mickm
[@sferik]: https://github.com/sferik
[@nicoolas25]: https://github.com/nicoolas25
[@challengee]: https://github.com/challengee
[@hannesg]: https://github.com/hannesg
[@krainboltgreene]: https://github.com/krainboltgreene
[@hundredwatt]: https://github.com/hundredwatt
[@jwinter]: https://github.com/jwinter
[@nerdrew]: https://github.com/nerdrew
[@kylekyle]: https://github.com/kylekyle
[@smudge]: https://github.com/smudge
[@mwitek]: https://github.com/mwitek
[@tonyta]: https://github.com/tonyta
[@jhbabon]: https://github.com/jhbabon
[@britishtea]: https://github.com/britishtea
[@janko-m]: https://github.com/janko-m
[@Bonias]: https://github.com/Bonias
[@HoneyryderChuck]: https://github.com/HoneyryderChuck
