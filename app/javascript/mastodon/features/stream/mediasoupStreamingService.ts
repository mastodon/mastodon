import * as mediasoupClient from "mediasoup-client";

export function startStream(peer, transport, onStreamChange: (s: MediaStream) => void) {
    var stream = new MediaStream();
    function addConsumer(consumer) {
        if (!consumer.supported) {
            console.log('consumer', consumer.id, 'not supported');
            return;
        }
        // if (consumer.kind === 'video') {
        //     autoAdjustProfile = makeAutoAdjustProfile(consumer);
        //     autoAdjustProfile();
        // }
        // consumer.on('stats', showStats);
        consumer.enableStats(1000);
        consumer.receive(transport)
            .then(function receiveTrack(track) {
                stream.addTrack(track);
                onStreamChange(stream)
                consumer.on('close', function closeConsumer() {
                    // Remove the old track.
                    console.log('removing the old track', track.id);
                    // clearStats(consumer.kind);
                    stream.removeTrack(track);
                    if (stream.getTracks().length === 0) {
                        // Replace the stream.
                        console.log('replacing stream');
                        stream = new MediaStream();
                        onStreamChange(stream)
                        // setVideoSource(video, stream);
                    }
                });
            })
            .catch(function onError(e) {
                console.log('Cannot add track', e);
            });
    }
    
    // Add consumers that are added later...
    peer.on('newconsumer', addConsumer);
    peer.on('closed', function closedPeer() {
        // setVideoSource(video);
    });
    // ... as well as the ones that were already present.
    for (var i = 0; i < peer.consumers.length; i ++) {
        addConsumer(peer.consumers[i]);
    }
}

export function subscribeChannel(cb: (peer: any, transport: any) => void){
   pubsubClient('streaming', 'NotSecret', false)
        .then(function havePubsub(ps: any) {
            const ws = ps.ws;
            const room = ps.room;
            const transport = room.createTransport('recv');
            // The server will only ever send us a single publisher.
            // Stream it if it is new...
            room.on('newpeer', function newPeer(peer) {
                console.log('New peer detected:', peer.name);
                cb(peer, transport)
            });
            // ... or if it already exists.
            if (ps.peers[0]) {
                console.log('Existing peer detected:', ps.peers[0].name);
                cb(ps.peers[0], transport)
            }
        })
        .catch(function onError(err) {
            alert('Cannot subscribe to channel: ' + err);
        });
}

export function pubsubClient(channel, password, isPublisher) {
    return new Promise(function executor(resolve, reject) {
        var kind = isPublisher ? 'publish' : 'subscribe';
        if (!new mediasoupClient.isDeviceSupported()) {
            alert('Sorry, WebRTC is not supported on this device');
            return;
        }

        var room;

        var reqid = 0;
        var pending = {};
        var errors = {};

        var wsurl;
        
        var match = window.location.search.match(/(^\?|&)u=([^&]*)/);
        if (match) {
            wsurl = decodeURIComponent(match[2]);
        }
        else {
            wsurl = window.location.href.replace(/^http/, 'ws')
                .replace(/^(wss?:\/\/.*)\/.*$/, '$1') + '/pubsub';
        }
        
        var ws = new WebSocket('ws://localhost:8000/pubsub');
        var connected = false;
        var peerName = isPublisher ? 'publisher' : '' + Math.random();
        function wsSend(obj) {
            // console.log('send:', obj);
            ws.send(JSON.stringify(obj));
        }
        ws.onopen = function onOpen() {
            connected = true;
            pending[++reqid] = function onPubsub(payload) {
                var turnServers = payload.turnServers || [];
                if (window.navigator && window.navigator.userAgent.match(/\sEdge\//)) {
                    // On Edge, having any secure turn (turns:...) URLs
                    // cause an InvalidAccessError, preventing connections.
                    turnServers = turnServers.map(function modServer(srv) {
                        var urls = srv.urls.filter(function modUrl(url) {
                            // Remove the turns: url.
                            return !url.match(/^turns:/);
                        });
                        return Object.assign({}, srv, {urls: urls});
                    });
                }

                room = new mediasoupClient.Room({
                    requestTimeout: 8000,
                    turnServers: turnServers,
                });

                room.on('request', function onRequest(request, callback, errback) {
                    if (ws.readyState !== ws.OPEN) {
                        return errback(Error('WebSocket is not open'));
                    }
        
                    pending[++ reqid] = callback;
                    errors[reqid] = errback;
                    wsSend({type: 'MS_SEND', payload: request, meta: {id: reqid, channel: channel}});
                });
                room.on('notify', function onNotification(notification) {
                    if (ws.readyState !== ws.OPEN) {
                        console.log(Error('WebSocket is not open'));
                        return;
                    }
                    wsSend({type: 'MS_SEND', payload: notification, meta: {channel: channel, notification: true}});
                });
        
                room.join(peerName)
                    .then(function (peers) {
                        console.log('Channel', channel, 'joined with peers', peers);
                        resolve({ws: ws, room: room, peers: peers});
                    })
                    .catch(reject);
            };
            errors[reqid] = function onError(payload) {
                alert('Cannot ' + kind + ' channel: ' + payload);
            };

            // FIXME: Send your own connection-initiation packet.
            wsSend({type: 'MS_SEND', payload: {kind: kind, password: password}, meta: {id: reqid, channel: channel}});
        };
        ws.onclose = function onClose(event) {
            if (room) {
                room.leave();
            }
            if (!connected) {
                reject(Error('Connection closed'));
            }
        };
        ws.onmessage = function onMessage(event) {
            // console.log('received', event.data);
            try {
                var action = JSON.parse(event.data);
                // console.log('recv:', action);
                switch (action.type) {
                    case 'MS_RESPONSE': {
                        var cb = pending[action.meta.id];
                        delete pending[action.meta.id];
                        delete errors[action.meta.id];
                        if (cb) {
                            cb(action.payload);
                        }
                        break;
                    }

                    case 'MS_ERROR': {
                        var errb = errors[action.meta.id];
                        delete pending[action.meta.id];
                        delete errors[action.meta.id];
                        if (errb) {
                            errb(action.payload);
                        }
                        break;
                    }

                    case 'MS_NOTIFY': {
                        room.receiveNotification(action.payload);
                        break;
                    }
                }
            }
            catch (e) {
                console.log('Error', e, 'handling', JSON.stringify(event.data));
            }
        }
    });
}