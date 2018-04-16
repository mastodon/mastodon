# websocket-extensions [![Build status](https://secure.travis-ci.org/faye/websocket-extensions-ruby.svg)](http://travis-ci.org/faye/websocket-extensions-ruby)

A minimal framework that supports the implementation of WebSocket extensions in
a way that's decoupled from the main protocol. This library aims to allow a
WebSocket extension to be written and used with any protocol library, by
defining abstract representations of frames and messages that allow modules to
co-operate.

`websocket-extensions` provides a container for registering extension plugins,
and provides all the functions required to negotiate which extensions to use
during a session via the `Sec-WebSocket-Extensions` header. By implementing the
APIs defined in this document, an extension may be used by any WebSocket library
based on this framework.

## Installation

```
$ gem install websocket-extensions
```

## Usage

There are two main audiences for this library: authors implementing the
WebSocket protocol, and authors implementing extensions. End users of a
WebSocket library or an extension should be able to use any extension by passing
it as an argument to their chosen protocol library, without needing to know how
either of them work, or how the `websocket-extensions` framework operates.

The library is designed with the aim that any protocol implementation and any
extension can be used together, so long as they support the same abstract
representation of frames and messages.

### Data types

The APIs provided by the framework rely on two data types; extensions will
expect to be given data and to be able to return data in these formats:

#### *Frame*

*Frame* is a structure representing a single WebSocket frame of any type. Frames
are simple objects that must have at least the following properties, which
represent the data encoded in the frame:

| property      | description                                                        |
| ------------  | ------------------------------------------------------------------ |
| `final`       | `true` if the `FIN` bit is set, `false` otherwise                  |
| `rsv1`        | `true` if the `RSV1` bit is set, `false` otherwise                 |
| `rsv2`        | `true` if the `RSV2` bit is set, `false` otherwise                 |
| `rsv3`        | `true` if the `RSV3` bit is set, `false` otherwise                 |
| `opcode`      | the numeric opcode (`0`, `1`, `2`, `8`, `9`, or `10`) of the frame |
| `masked`      | `true` if the `MASK` bit is set, `false` otherwise                 |
| `masking_key` | a 4-byte string if `masked` is `true`, otherwise `nil`             |
| `payload`     | a string containing the (unmasked) application data                |

#### *Message*

A *Message* represents a complete application message, which can be formed from
text, binary and continuation frames. It has the following properties:

| property | description                                                       |
| -------- | ----------------------------------------------------------------- |
| `rsv1`   | `true` if the first frame of the message has the `RSV1` bit set   |
| `rsv2`   | `true` if the first frame of the message has the `RSV2` bit set   |
| `rsv3`   | `true` if the first frame of the message has the `RSV3` bit set   |
| `opcode` | the numeric opcode (`1` or `2`) of the first frame of the message |
| `data`   | the concatenation of all the frame payloads in the message        |

### For driver authors

A driver author is someone implementing the WebSocket protocol proper, and who
wishes end users to be able to use WebSocket extensions with their library.

At the start of a WebSocket session, on both the client and the server side,
they should begin by creating an extension container and adding whichever
extensions they want to use.

```rb
require 'websocket/extensions'
require 'permessage_deflate'

exts = WebSocket::Extensions.new
exts.add(PermessageDeflate)
```

In the following examples, `exts` refers to this `Extensions` instance.

#### Client sessions

Clients will use the methods `generate_offer` and `activate(header)`.

As part of the handshake process, the client must send a
`Sec-WebSocket-Extensions` header to advertise that it supports the registered
extensions. This header should be generated using:

```rb
request_headers['Sec-WebSocket-Extensions'] = exts.generate_offer
```

This returns a string, for example `"permessage-deflate;
client_max_window_bits"`, that represents all the extensions the client is
offering to use, and their parameters. This string may contain multiple offers
for the same extension.

When the client receives the handshake response from the server, it should pass
the incoming `Sec-WebSocket-Extensions` header in to `exts` to activate the
extensions the server has accepted:

```rb
exts.activate(response_headers['Sec-WebSocket-Extensions'])
```

If the server has sent any extension responses that the client does not
recognize, or are in conflict with one another for use of RSV bits, or that use
invalid parameters for the named extensions, then `exts.activate` will `raise`.
In this event, the client driver should fail the connection with closing code
`1010`.

#### Server sessions

Servers will use the method `generate_response(header)`.

A server session needs to generate a `Sec-WebSocket-Extensions` header to send
in its handshake response:

```rb
client_offer = request_env['HTTP_SEC_WEBSOCKET_EXTENSIONS']
ext_response = exts.generate_response(client_offer)

response_headers['Sec-WebSocket-Extensions'] = ext_response
```

Calling `exts.generate_response(header)` activates those extensions the client
has asked to use, if they are registered, asks each extension for a set of
response parameters, and returns a string containing the response parameters for
all accepted extensions.

#### In both directions

Both clients and servers will use the methods `valid_frame_rsv(frame)`,
`process_incoming_message(message)` and `process_outgoing_message(message)`.

The WebSocket protocol requires that frames do not have any of the `RSV` bits
set unless there is an extension in use that allows otherwise. When processing
an incoming frame, sessions should pass a *Frame* object to:

```rb
exts.valid_frame_rsv(frame)
```

If this method returns `false`, the session should fail the WebSocket connection
with closing code `1002`.

To pass incoming messages through the extension stack, a session should
construct a *Message* object according to the above datatype definitions, and
call:

```rb
message = exts.process_incoming_message(message)
```

If any extensions fail to process the message, then this call will `raise` an
error and the session should fail the WebSocket connection with closing code
`1010`. Otherwise, `message` should be passed on to the application.

To pass outgoing messages through the extension stack, a session should
construct a *Message* as before, and call:

```rb
message = exts.process_outgoing_message(message)
```

If any extensions fail to process the message, then this call will `raise` an
error and the session should fail the WebSocket connection with closing code
`1010`. Otherwise, `message` should be converted into frames (with the message's
`rsv1`, `rsv2`, `rsv3` and `opcode` set on the first frame) and written to the
transport.

At the end of the WebSocket session (either when the protocol is explicitly
ended or the transport connection disconnects), the driver should call:

```rb
exts.close
```

### For extension authors

An extension author is someone implementing an extension that transforms
WebSocket messages passing between the client and server. They would like to
implement their extension once and have it work with any protocol library.

Extension authors will not install `websocket-extensions` or call it directly.
Instead, they should implement the following API to allow their extension to
plug into the `websocket-extensions` framework.

An `Extension` is any object that has the following properties:

| property | description                                                                  |
| -------- | ---------------------------------------------------------------------------- |
| `name`   | a string containing the name of the extension as used in negotiation headers |
| `type`   | a string, must be `"permessage"`                                             |
| `rsv1`   | either `true` if the extension uses the RSV1 bit, `false` otherwise          |
| `rsv2`   | either `true` if the extension uses the RSV2 bit, `false` otherwise          |
| `rsv3`   | either `true` if the extension uses the RSV3 bit, `false` otherwise          |

It must also implement the following methods:

```rb
ext.create_client_session
```

This returns a *ClientSession*, whose interface is defined below.

```rb
ext.create_server_session(offers)
```

This takes an array of offer params and returns a *ServerSession*, whose
interface is defined below. For example, if the client handshake contains the
offer header:

```
Sec-WebSocket-Extensions: permessage-deflate; server_no_context_takeover; server_max_window_bits=8, \
                          permessage-deflate; server_max_window_bits=15
```

then the `permessage-deflate` extension will receive the call:

```rb
ext.create_server_session([
  {'server_no_context_takeover' => true, 'server_max_window_bits' => 8},
  {'server_max_window_bits' => 15}
])
```

The extension must decide which set of parameters it wants to accept, if any,
and return a *ServerSession* if it wants to accept the parameters and `nil`
otherwise.

#### *ClientSession*

A *ClientSession* is the type returned by `ext.create_client_session`. It must
implement the following methods, as well as the *Session* API listed below.

```rb
client_session.generate_offer
# e.g.  -> [
#            {'server_no_context_takeover' => true, 'server_max_window_bits' => 8},
#            {'server_max_window_bits' => 15}
#          ]
```

This must return a set of parameters to include in the client's
`Sec-WebSocket-Extensions` offer header. If the session wants to offer multiple
configurations, it can return an array of sets of parameters as shown above.

```rb
client_session.activate(params) # -> true
```

This must take a single set of parameters from the server's handshake response
and use them to configure the client session. If the client accepts the given
parameters, then this method must return `true`. If it returns any other value,
the framework will interpret this as the client rejecting the response, and will
`raise`.

#### *ServerSession*

A *ServerSession* is the type returned by `ext.create_server_session(offers)`. It
must implement the following methods, as well as the *Session* API listed below.

```rb
server_session.generate_response
# e.g.  -> {'server_max_window_bits' => 8}
```

This returns the set of parameters the server session wants to send in its
`Sec-WebSocket-Extensions` response header. Only one set of parameters is
returned to the client per extension. Server sessions that would confict on
their use of RSV bits are not activated.

#### *Session*

The *Session* API must be implemented by both client and server sessions. It
contains three methods: `process_incoming_message(message)` and
`process_outgoing_message(message)`.

```rb
message = session.process_incoming_message(message)
```

The session must implement this method to take an incoming *Message* as defined
above, transform it in any way it needs, then return it. If there is an error
processing the message, this method should `raise` an error.

```rb
message = session.process_outgoing_message(message)
```

The session must implement this method to take an outgoing *Message* as defined
above, transform it in any way it needs, then return it. If there is an error
processing the message, this method should `raise` an error.

```rb
session.close
```

The framework will call this method when the WebSocket session ends, allowing
the session to release any resources it's using.

## Examples

* Consumer: [websocket-driver](https://github.com/faye/websocket-driver-ruby)
* Provider: [permessage-deflate](https://github.com/faye/permessage-deflate-ruby)
