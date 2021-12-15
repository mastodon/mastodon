'use strict';
const mediasoup = require('mediasoup');

const msOptions = {
    rtcIPv4: process.env.RTC_IPV4 || true,
    rtcIPv6: process.env.RTC_IPV6 || false,
};
if (process.env.RTC_ANNOUNCED_IPV4) {
    // This is the external IP address that routes to the current
    // instance.  For cloud providers or Kubernetes, this
    // will be a different address than the connected network
    // interface will use.
    msOptions.rtcAnnouncedIPv4 = process.env.RTC_ANNOUNCED_IPV4;
}
if (process.env.RTC_ANNOUNCED_IPV6) {
    msOptions.rtcAnnouncedIPv6 = process.env.RTC_ANNOUNCED_IPV6;
}
if (process.env.LOG_LEVEL) {
    console.log('Setting logLevel to', process.env.LOG_LEVEL)
    msOptions.logLevel = process.env.LOG_LEVEL;
    msOptions.logTags = [ 'info', 'ice', 'dlts', 'rtp', 'srtp', 'rtcp', 'rbe', 'rtx' ];
}
msOptions.numWorkers = 1;
msOptions.rtcMaxPort = 10030;
const ms = mediasoup.Server(msOptions);

const PUBLISHER_PEER = 'publisher';
const rooms = {};
const MEDIA_CODECS = [
    {
      kind        : "audio",
      name        : "opus",
      clockRate   : 48000,
      channels    : 2,
      parameters  :
      {
        useinbandfec : 1
      }
    },
    /*
    // FIXME: Safari 11 doesn't suppport vp8, so we need just h264 for portability.
    {
        kind      : "video",
        name      : "vp8",
        clockRate : 90000
    },
    */
    {
      kind       : "video",
      name       : "VP8",
      clockRate  : 90000,
      parameters :
      {
        "packetization-mode"      : 1,
        "profile-level-id"        : "42e01f",
        "level-asymmetry-allowed" : 1
      }
    },
  ];

function publish(addr, channel, ws) {
    handlePubsub(addr, channel, ws, true);
}

function subscribe(addr, channel, ws) {
    handlePubsub(addr, channel, ws, false);
}

function handlePubsub(addr, channel, ws, isPublisher) {
    var room = rooms[channel];
    if (!room) {
        room = rooms[channel] = ms.Room(MEDIA_CODECS);
    }
    var peer;
    function sendAction(obj) {
        if (ws.readyState !== ws.OPEN) {
            return;
        }
        ws.send(JSON.stringify(obj));
    }
    var oldClose = ws.onclose;
    ws.onclose = function onClose(event) {
        if (peer) {
            peer.close();
        }
        oldClose.call(this, event);
    };
    ws.onmessage = function onMessage(event) {
        // console.log(addr, 'got message', event.data);
        try {
            const action = JSON.parse(event.data);
            switch (action.type) {
                case 'MS_SEND': {
                    var target;
                    switch (action.payload.target) {
                        case 'room':
                            target = room;
                            break;
                        case 'peer':
                            target = peer;
                            break;
                    }
                    if (action.meta.notification) {
                        if (!target) {
                            console.log(addr, 'unknown notification target', action.payload.target);
                            break;
                        }
                        target.receiveNotification(action.payload);
                        break;
                    }

                    if (!target) {
                        console.log(addr, 'unknown request target', action.payload.target);
                        sendAction({type: 'MS_ERROR', payload: 'unknown request target', meta: action.meta});
                        break;
                    }
                    if (action.payload.method === 'join') {
                        if (isPublisher) {
                            // Publisher has a reserved name.
                            action.payload.peerName = PUBLISHER_PEER;
                        }
                        else if (action.payload.peerName === PUBLISHER_PEER) {
                            // They tried to be the publisher, but weren't authed.
                            action.payload.peerName = 'pseudo' + PUBLISHER_PEER;
                        }
                        // Kick out the old peer.
                        var oldPeer = room.getPeerByName(action.payload.peerName);
                        if (oldPeer) {
                            oldPeer.close();
                        }
                    }
                    target.receiveRequest(action.payload)
                        .then(function onResponse(response) {
                            if (action.payload.method === 'join') {
                                // Detected a join request, so get the peer.
                                var peerName = action.payload.peerName;
                                peer = room.getPeerByName(peerName);
                                peer.on('notify', function onNotify(notification) {
                                    if (notification.method === 'newPeer' || notification.method === 'peerClosed' ) {
                                        if (!isPublisher && notification.name !== PUBLISHER_PEER) {
                                            // Skip the notification to hide all but the publisher.
                                            return;
                                        }
                                    }
                                    // console.log(addr, 'sending notification', notification);
                                    sendAction({type: 'MS_NOTIFY', payload: notification, meta: {channel: channel}});
                                });
                                console.log(addr, 'new peer joined the room', peerName);
                                if (!isPublisher) {
                                    // Filter out all peers but the publisher.
                                    response = Object.assign({}, response,
                                        {peers: response.peers.filter(function (peer) {
                                            return (peer.name === PUBLISHER_PEER);
                                        })});
                                }
                            }
                            // console.log(addr, 'sending response', response);
                            sendAction({type: 'MS_RESPONSE', payload: response, meta: action.meta});
                        })
                        .catch(function onError(err) {
                            sendAction({type: 'MS_ERROR', payload: err, meta: action.meta});
                        });
                    break;
                }

                default:
                    throw Error('Unrecognized action type ' + action.type);
            }
        } catch (e) {
            console.log(addr, 'error', e, 'handling message', event.data);
        }
    };
}

module.exports = {
    publish,
    subscribe,
};
