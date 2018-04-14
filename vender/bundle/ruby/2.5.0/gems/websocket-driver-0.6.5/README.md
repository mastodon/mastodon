# websocket-driver [![Build Status](https://travis-ci.org/faye/websocket-driver-ruby.svg)](https://travis-ci.org/faye/websocket-driver-ruby)

This module provides a complete implementation of the WebSocket protocols that
can be hooked up to any TCP library. It aims to simplify things by decoupling
the protocol details from the I/O layer, such that users only need to implement
code to stream data in and out of it without needing to know anything about how
the protocol actually works. Think of it as a complete WebSocket system with
pluggable I/O.

Due to this design, you get a lot of things for free. In particular, if you hook
this module up to some I/O object, it will do all of this for you:

* Select the correct server-side driver to talk to the client
* Generate and send both server- and client-side handshakes
* Recognize when the handshake phase completes and the WS protocol begins
* Negotiate subprotocol selection based on `Sec-WebSocket-Protocol`
* Negotiate and use extensions via the
  [websocket-extensions](https://github.com/faye/websocket-extensions-ruby)
  module
* Buffer sent messages until the handshake process is finished
* Deal with proxies that defer delivery of the draft-76 handshake body
* Notify you when the socket is open and closed and when messages arrive
* Recombine fragmented messages
* Dispatch text, binary, ping, pong and close frames
* Manage the socket-closing handshake process
* Automatically reply to ping frames with a matching pong
* Apply masking to messages sent by the client

This library was originally extracted from the [Faye](http://faye.jcoglan.com)
project but now aims to provide simple WebSocket support for any Ruby server or
I/O system.


## Installation

```
$ gem install websocket-driver
```


## Usage

To build either a server-side or client-side socket, the only requirement is
that you supply a `socket` object with these methods:

* `socket.url` - returns the full URL of the socket as a string.
* `socket.write(string)` - writes the given string to a TCP stream.

Server-side sockets require one additional method:

* `socket.env` - returns a Rack-style env hash that will contain some of the
  following fields. Their values are strings containing the value of the named
  header, unless stated otherwise.
  * `HTTP_CONNECTION`
  * `HTTP_HOST`
  * `HTTP_ORIGIN`
  * `HTTP_SEC_WEBSOCKET_EXTENSIONS`
  * `HTTP_SEC_WEBSOCKET_KEY`
  * `HTTP_SEC_WEBSOCKET_KEY1`
  * `HTTP_SEC_WEBSOCKET_KEY2`
  * `HTTP_SEC_WEBSOCKET_PROTOCOL`
  * `HTTP_SEC_WEBSOCKET_VERSION`
  * `HTTP_UPGRADE`
  * `rack.input`, an `IO` object representing the request body
  * `REQUEST_METHOD`, the request's HTTP verb


### Server-side with Rack

To handle a server-side WebSocket connection, you need to check whether the
request is a WebSocket handshake, and if so create a protocol driver for it.
You must give the driver an object with the `env`, `url` and `write` methods. A
simple example might be:

```ruby
require 'websocket/driver'
require 'eventmachine'

class WS
  attr_reader :env, :url

  def initialize(env)
    @env = env

    secure = Rack::Request.new(env).ssl?
    scheme = secure ? 'wss:' : 'ws:'
    @url = scheme + '//' + env['HTTP_HOST'] + env['REQUEST_URI']

    @driver = WebSocket::Driver.rack(self)

    env['rack.hijack'].call
    @io = env['rack.hijack_io']

    EM.attach(@io, Reader) { |conn| conn.driver = @driver }

    @driver.start
  end

  def write(string)
    @io.write(string)
  end

  module Reader
    attr_writer :driver

    def receive_data(string)
      @driver.parse(string)
    end
  end
end
```

To explain what's going on here: the `WS` class implements the `env`, `url` and
`write(string)` methods as required. When instantiated with a Rack environment,
it stores the environment and infers the complete URL from it.  Having set up
the `env` and `url`, it asks `WebSocket::Driver` for a server-side driver for
the socket. Then it uses the Rack hijack API to gain access to the TCP stream,
and uses EventMachine to stream in incoming data from the client, handing
incoming data off to the driver for parsing. Finally, we tell the driver to
`start`, which will begin sending the handshake response.  This will invoke the
`WS#write` method, which will send the response out over the TCP socket.

Having defined this class we could use it like this when handling a request:

```ruby
if WebSocket::Driver.websocket?(env)
  socket = WS.new(env)
end
```

The driver API is described in full below.


### Server-side with TCP

You can also handle WebSocket connections in a bare TCP server, if you're not
using Rack and don't want to implement HTTP parsing yourself. For this, your
socket object only needs a `write` method.

The driver will emit a `:connect` event when a request is received, and at this
point you can detect whether it's a WebSocket and handle it as such. Here's an
example using an EventMachine TCP server.

```ruby
module Connection
  def initialize
    @driver = WebSocket::Driver.server(self)

    @driver.on :connect, -> (event) do
      if WebSocket::Driver.websocket?(@driver.env)
        @driver.start
      else
        # handle other HTTP requests
      end
    end

    @driver.on :message, -> (e) { @driver.text(e.data) }
    @driver.on :close,   -> (e) { close_connection_after_writing }
  end

  def receive_data(data)
    @driver.parse(data)
  end

  def write(data)
    send_data(data)
  end
end

EM.run {
  EM.start_server('127.0.0.1', 4180, Connection)
}
```

In the `:connect` event, `@driver.env` is a Rack env representing the request.
If the request has a body, it will be in the `@driver.env['rack.input']` stream,
but only as much of the body as you have so far routed to it using the `parse`
method.


### Client-side

Similarly, to implement a WebSocket client you need an object with `url` and
`write` methods. Once you have one such object, you ask for a driver for it:

```ruby
driver = WebSocket::Driver.client(socket)
```

After this you use the driver API as described below to process incoming data
and send outgoing data.

Client drivers have two additional methods for reading the HTTP data that was
sent back by the server:

* `driver.status` - the integer value of the HTTP status code
* `driver.headers` - a hash-like object containing the response headers


### HTTP Proxies

The client driver supports connections via HTTP proxies using the `CONNECT`
method. Instead of sending the WebSocket handshake immediately, it will send a
`CONNECT` request, wait for a `200` response, and then proceed as normal.

To use this feature, call `proxy = driver.proxy(url)` where `url` is the origin
of the proxy, including a username and password if required. This produces an
object that manages the process of connecting via the proxy. You should call
`proxy.start` to begin the connection process, and pass data you receive via the
socket to `proxy.parse(data)`. When the proxy emits `:connect`, you should then
start sending incoming data to `driver.parse(data)` as normal, and call
`driver.start`.

```rb
proxy = driver.proxy('http://username:password@proxy.example.com')

proxy.on :connect, -> (event) do
  driver.start
end
```

The proxy's `:connect` event is also where you should perform a TLS handshake on
your TCP stream, if you are connecting to a `wss:` endpoint.

In the event that proxy connection fails, `proxy` will emit an `:error`. You can
inspect the proxy's response via `proxy.status` and `proxy.headers`.

```rb
proxy.on :error, -> (error) do
  puts error.message
  puts proxy.status
  puts proxy.headers.inspect
end
```

Before calling `proxy.start` you can set custom headers using
`proxy.set_header`:

```rb
proxy.set_header('User-Agent', 'ruby')
proxy.start
```


### Driver API

Drivers are created using one of the following methods:

```ruby
driver = WebSocket::Driver.rack(socket, options)
driver = WebSocket::Driver.server(socket, options)
driver = WebSocket::Driver.client(socket, options)
```

The `rack` method returns a driver chosen using the socket's `env`. The `server`
method returns a driver that will parse an HTTP request and then decide which
driver to use for it using the `rack` method. The `client` method always returns
a driver for the RFC version of the protocol with masking enabled on outgoing
frames.

The `options` argument is optional, and is a hash. It may contain the following
keys:

* `:max_length` - the maximum allowed size of incoming message frames, in bytes.
  The default value is `2^26 - 1`, or 1 byte short of 64 MiB.
* `:protocols` - an array of strings representing acceptable subprotocols for
  use over the socket. The driver will negotiate one of these to use via the
  `Sec-WebSocket-Protocol` header if supported by the other peer.

All drivers respond to the following API methods, but some of them are no-ops
depending on whether the client supports the behaviour.

Note that most of these methods are commands: if they produce data that should
be sent over the socket, they will give this to you by calling
`socket.write(string)`.

#### `driver.on :open, -> (event) { }`

Adds a callback block to execute when the socket becomes open.

#### `driver.on :message, -> (event) { }`

Adds a callback block to execute when a message is received. `event` will have a
`data` attribute containing either a string in the case of a text message or an
array of integers in the case of a binary message.

#### `driver.on :error, -> (event) { }`

Adds a callback to execute when a protocol error occurs due to the other peer
sending an invalid byte sequence. `event` will have a `message` attribute
describing the error.

#### `driver.on :close, -> (event) { }`

Adds a callback block to execute when the socket becomes closed. The `event`
object has `code` and `reason` attributes.

#### `driver.add_extension(extension)`

Registers a protocol extension whose operation will be negotiated via the
`Sec-WebSocket-Extensions` header. `extension` is any extension compatible with
the [websocket-extensions](https://github.com/faye/websocket-extensions-ruby)
framework.

#### `driver.set_header(name, value)`

Sets a custom header to be sent as part of the handshake response, either from
the server or from the client. Must be called before `start`, since this is when
the headers are serialized and sent.

#### `driver.start`

Initiates the protocol by sending the handshake - either the response for a
server-side driver or the request for a client-side one. This should be the
first method you invoke.  Returns `true` if and only if a handshake was sent.

#### `driver.parse(string)`

Takes a string and parses it, potentially resulting in message events being
emitted (see `on('message')` above) or in data being sent to `socket.write`.
You should send all data you receive via I/O to this method.

#### `driver.text(string)`

Sends a text message over the socket. If the socket handshake is not yet
complete, the message will be queued until it is. Returns `true` if the message
was sent or queued, and `false` if the socket can no longer send messages.

#### `driver.binary(array)`

Takes an array of byte-sized integers and sends them as a binary message. Will
queue and return `true` or `false` the same way as the `text` method. It will
also return `false` if the driver does not support binary messages.

#### `driver.ping(string = '', &callback)`

Sends a ping frame over the socket, queueing it if necessary. `string` and the
`callback` block are both optional. If a callback is given, it will be invoked
when the socket receives a pong frame whose content matches `string`. Returns
`false` if frames can no longer be sent, or if the driver does not support
ping/pong.

#### `driver.pong(string = '')`

Sends a pong frame over the socket, queueing it if necessary. `string` is
optional. Returns `false` if frames can no longer be sent, or if the driver does
not support ping/pong.

You don't need to call this when a ping frame is received; pings are replied to
automatically by the driver. This method is for sending unsolicited pongs.

#### `driver.close`

Initiates the closing handshake if the socket is still open. For drivers with no
closing handshake, this will result in the immediate execution of the
`on('close')` callback. For drivers with a closing handshake, this sends a
closing frame and `emit('close')` will execute when a response is received or a
protocol error occurs.

#### `driver.version`

Returns the WebSocket version in use as a string. Will either be `hixie-75`,
`hixie-76` or `hybi-$version`.

#### `driver.protocol`

Returns a string containing the selected subprotocol, if any was agreed upon
using the `Sec-WebSocket-Protocol` mechanism. This value becomes available after
`emit('open')` has fired.
