'use strict';
const fs = require('fs');
const url = require('url');

const express = require('express');
const WebSocket = require('ws');

const auth = require('./auth');
const wsServer = require('./wsserver');

const app = express();
let server;

if (process.env.HTTPS_HOST) {
    // HTTPS server.
    const base = process.env.HTTPS_HOST;
    const PORT = Number(process.env.PORT) || 443;
    server = require('https').createServer({
        cert: fs.readFileSync(`${__dirname}/certs/${base}.crt`),
        key: fs.readFileSync(`${__dirname}/certs/${base}.key`),
    }, app);
    console.log(`Listening for HTTPS on ${process.env.HTTPS_HOST || '0.0.0.0'}:${PORT}`);
    server.listen(PORT, process.env.HTTPS_HOST);
}
else {
    // HTTP server.
    const PORT = Number(process.env.PORT) || 80;
    server = require('http').createServer(app);
    console.log(`Listening for HTTP on ${process.env.HOST || '0.0.0.0'}:${PORT}`);
    server.listen(PORT, process.env.HOST);
}

const exst = express.static(`${__dirname}/../app`);
app.use('/', exst);
if (process.env.INGRESS_PATH) {
    console.log(`Enabling INGRESS_PATH ${process.env.INGRESS_PATH}`);
    app.use(process.env.INGRESS_PATH, exst);
}

const wss = new WebSocket.Server({noServer: true});
function heartbeat() {
    // Mark this socket as alive.
    this.isAlive = true;
}
function noop() {
    // Do nothing.
}
const pinger = setInterval(function ping() {
    // Ping all the clients to see if they're dead.
    wss.clients.forEach(function each(ws) {
        if (ws.isAlive === false) {
            // Dead for a whole cycle, so close.
            return ws.terminate();
        }
        // Mark as dead until we know otherwise.
        ws.isAlive = false;
        ws.ping(noop);
    })
}, 30000);

server.on('upgrade', function upgrade(req, socket, head) {
    // Upgrade all /pubsub connections to WebSocket.
    const pathname = url.parse(req.url).pathname;
    const addr = socket.remoteAddress + ' ' + socket.remotePort;
    if (!pathname.match(/\/pubsub$/)) {
        console.log(addr, 'not connecting to /pubsub');
        socket.destroy();
        return;
    }

    wss.handleUpgrade(req, socket, head, function done(ws) {
        ws.isAlive = true;
        ws.on('pong', heartbeat);
        ws.onmessage = function onMessage(event) {
            try {
                const action = JSON.parse(event.data);
                if (action.type === 'MS_SEND') {
                    // kind is either 'publish' or 'subscribe'.
                    auth.authorize(addr, action.meta.channel, action.payload)
                        .then((payload) => {
                            ws.send(JSON.stringify({type: 'MS_RESPONSE', payload: payload, meta: action.meta}));
                            wsServer[payload.kind](addr, action.meta.channel, ws);
                        })
                        .catch((e) => {
                            console.log(addr, 'cannot authorize', e);
                            socket.destroy();
                        });
                    return;
                }
                throw Error('unauthorized');
            } catch (e) {
                console.log(addr, 'error', e, 'handling message', event.data);
                socket.destroy();
            }
        };
        ws.onerror = function onError(event) {
            console.log(addr, 'error', event.message, event.error);
        };
        ws.onclose = function onClose(event) {
            console.log(addr, 'closed');
        };
    });
});
