Streaming API
=============

Your application can use a server-sent events endpoint to receive updates in real-time. Server-sent events is an incredibly simple transport method that relies entirely on chunked-encoding transfer, i.e. the HTTP connection is kept open and receives new data periodically.

### Endpoints:

**GET /api/v1/streaming/user**

Returns events that are relevant to the authorized user, i.e. home timeline and notifications

**GET /api/v1/streaming/public**

Returns all public statuses

**GET /api/v1/streaming/hashtag**

Returns all public statuses for a particular hashtag (query param `tag`)

### Stream contents

The stream will contain events as well as heartbeat comments. Lines that begin with a colon (`:`) can be ignored by parsers, they are simply there to keep the connection open. Events have this structure:

```
event: name
data: payload

```

[See MDN](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#Event_stream_format)

### Event types

|Event|Description|What's in the payload|
|-----|-----------|---------------------|
|`update`|A new status has appeared!|Status|
|`notification`|A new notification|Notification|
|`delete`|A status has been deleted|ID of the deleted status|

The payload is JSON-encoded.
