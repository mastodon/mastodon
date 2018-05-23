### 0.6.5 / 2017-01-22

* Provide a pure-Ruby fallback for the native unmasking code

### 0.6.4 / 2016-05-20

* Amend warnings issued when running with -W2
* Make sure message strings passed in by the app are transcoded to UTF-8
* Copy strings if necessary for frozen-string compatibility

### 0.6.3 / 2015-11-06

* Reject draft-76 handshakes if their Sec-WebSocket-Key headers are invalid
* Throw a more helpful error if a client is created with an invalid URL

### 0.6.2 / 2015-07-18

* When the peer sends a close frame with no error code, emit 1000

### 0.6.1 / 2015-07-13

* Fix how events are stored in `EventEmitter` to fix a backward-compatibility
  violation introduced in the last release
* Use the `Array#pack` and `String#unpack` methods for reading/writing numbers
  to buffers rather than including duplicate logic for this

### 0.6.0 / 2015-07-08

* Use `SecureRandom` to generate the `Sec-WebSocket-Key` header
* Allow the parser to recover cleanly if event listeners raise an error
* Let the `on()` method take a lambda as a positional argument rather than a block
* Add a `pong` method for sending unsolicited pong frames

### 0.5.4 / 2015-03-29

* Don't emit extra close frames if we receive a close frame after we already
  sent one
* Fail the connection when the driver receives an invalid
  `Sec-WebSocket-Extensions` header

### 0.5.3 / 2015-02-22

* Don't treat incoming data as WebSocket frames if a client driver is closed
  before receiving the server handshake

### 0.5.2 / 2015-02-19

* Don't emit multiple `error` events

### 0.5.1 / 2014-12-18

* Don't allow drivers to be created with unrecognized options

### 0.5.0 / 2014-12-13

* Support protocol extensions via the websocket-extensions module

### 0.4.0 / 2014-11-08

* Support connection via HTTP proxies using `CONNECT`

### 0.3.5 / 2014-10-04

* Fix bug where the `Server` driver doesn't pass `ping` callbacks to its
  delegate
* Fix an arity error when calling `fail_request`
* Allow `close` to be called before `start` to close the driver

### 0.3.4 / 2014-07-06

* Don't hold references to frame buffers after a message has been emitted
* Make sure that `protocol` and `version` are exposed properly by the TCP driver
* Correct HTTP header parsing based on RFC 7230; header names cannot contain
  backslashes

### 0.3.3 / 2014-04-24

* Fix problems with loading C and Java native extension code
* Correct the acceptable characters used in the HTTP parser
* Correct the draft-76 status line reason phrase

### 0.3.2 / 2013-12-29

* Expand `max_length` to cover sequences of continuation frames and
  `draft-{75,76}`
* Decrease default maximum frame buffer size to 64MB
* Stop parsing when the protocol enters a failure mode, to save CPU cycles

### 0.3.1 / 2013-12-03

* Add a `max_length` option to limit allowed frame size

### 0.3.0 / 2013-09-09

* Support client URLs with Basic Auth credentials

### 0.2.3 / 2013-08-04

* Fix bug in EventEmitter#emit when listeners are removed

### 0.2.2 / 2013-08-04

* Fix bug in EventEmitter#listener_count for unregistered events

### 0.2.1 / 2013-07-05

* Queue sent messages if the client has not begun trying to connect
* Encode all strings sent to I/O as `ASCII-8BIT`

### 0.2.0 / 2013-05-12

* Add API for setting and reading headers
* Add Driver.server() method for getting a driver for TCP servers

### 0.1.0 / 2013-05-04

* First stable release

### 0.0.0 / 2013-04-22

* First release
* Proof of concept for people to try out
* Might be unstable
