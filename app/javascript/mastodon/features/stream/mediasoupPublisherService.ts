import * as mediasoupClient from "mediasoup-client";
import { pubsubClient } from "./mediasoupStreamingService";

var ws;
var room;
var stream;
var transport;
var video;
var producers = {};
var sendStream;

var lastProduced = {};

export function publishStream({sendStream, id}: {sendStream: MediaStream, id: string}) {
    // stopPublishClick();


    pubsubClient(id, 'NotSecret', true)
        .then(function havePubsub(ps: any) {
            ws = ps.ws;
            room = ps.room;
            producers = {};

            // Now actually stream the selected video to the output.
            transport = room.createTransport('send');
            maybeStream(sendStream);
        })
        .catch(function onError(err) {
            alert('Cannot publish to channel: ' + err);
        });
}

 function connectProducer(type, track) {
    if (producers[type]) {
        if (room && track && lastProduced[type] === track.id) {
            return;
        }
        console.log('stop producing', type, producers[type].track.id);
        producers[type].close();
        delete producers[type];
        delete lastProduced[type];
    }
    if (room && track) {
        console.log('producing', type, track.id);
        lastProduced[type] = track.id;
        var opts = type === 'video' ? {simulcast: true} : {};
        producers[type] = room.createProducer(track, opts);
        // producers[type].on('stats', showStats);
        producers[type].enableStats(1000);
        producers[type].send(transport);
        producers[type].on('close', function closeProducer() {
            // clearStats(type);
        });
    }
}

function maybeStream(stream) {
    // Actually begin the stream if we can.
    if (!stream) {
        console.log('no sending stream yet');
        return;
    }
    sendStream = stream;

    console.log('streaming');
    function doConnects() {
        if (!stream) {
            return;
        }
        var atrack = stream.getAudioTracks();
        var vtrack = stream.getVideoTracks();
        function notEnded(track) {
            if (track.readyState === 'ended' && stream.removeTrack) {
                stream.removeTrack(track);
                return false;
            }
            return true;
        }
        connectProducer('audio', atrack.find(notEnded));
        connectProducer('video', vtrack.find(notEnded));
    }
    whenStreamIsActive(function getStream() { return stream }, doConnects);
}
var streamActiveTimeout = {};
function whenStreamIsActive(getStream, callback) {
    var stream = getStream();
    if (!stream) {
        return;
    }
    var id = stream.id;
    if (stream.active) {
        callback();
    }
    else if ('onactive' in stream) {
        stream.onactive = maybeCallback;
    }
    else if (!streamActiveTimeout[id]) {
        maybeCallback();
    }
    function maybeCallback() {
        delete streamActiveTimeout[id];
        var stream = getStream();
        if (!stream) {
            return;
        }
        if (stream.onactive === maybeCallback) {
            stream.onactive = null;
        }
        if (!stream.active) {
            // Safari needs a timeout to try again.
            // console.log('try again');
            streamActiveTimeout[id] = setTimeout(maybeCallback, 500);
            return;
        }
        callback();
    }
}

function hookup(capturing, newStream, newVideoStream) {
    var vtrack = capturing.stream.getVideoTracks();
    if (capturing.video && vtrack.length > 0) {
        for (var track of newStream.getVideoTracks()) {
            track.stop();
        }
        newStream.addTrack(vtrack[0]);
        if (newVideoStream) {
            for (var track of newVideoStream.getVideoTracks()) {
                track.stop();
            }
            newVideoStream.addTrack(vtrack[0]);
        }
    }
    var atrack = capturing.stream.getAudioTracks();
    if (capturing.audio && atrack.length > 0) {
        for (var track of newStream.getAudioTracks()) {
            track.stop();
        }
        newStream.addTrack(atrack[0]);
    }
    maybeStream(newStream);
}
