'use strict';
const querystring = require('querystring');
const url = require('url');
const crypto = require('crypto');

const SEND_PASSWORD = process.env.SEND_PASSWORD || 'ChangeMe';
const RECV_PASSWORD = process.env.RECV_PASSWORD || 'NotSecret';
const TURN_SERVERS = process.env.TURN_SERVERS ? process.env.TURN_SERVERS.split(',') : [];
const PASSWORD_EXPIRY_SECONDS = 300;


function getTurnServers(urls, key) {
    if (!urls.length) {
        return [];
    }
    if (key) {
        // Return the TURN REST API credential.
        const timestamp = Math.floor(Date.now() / 1000) + PASSWORD_EXPIRY_SECONDS;
        const temporary_username = String(timestamp) + ':msbe';
        const hmac = crypto.createHmac('sha1', key).update(temporary_username).digest('base64');
        return [{urls: urls,
            username: temporary_username,
            credential: hmac,
            credentialType: 'password',
        }];
    }
    else {
        // No credentials;
        return [{urls: urls}];
    }
};


function getPayload(kind) {
    return {
        kind: kind,
        turnServers: getTurnServers(TURN_SERVERS, process.env.TURN_AUTH_KEY)
    };
}

function authorize(addr, channel, request) {
    if (request.kind === 'subscribe') {
        console.log(addr, `Authorizing subscriber to ${channel}`);
        if (request.password === RECV_PASSWORD) {
            return Promise.resolve(getPayload('subscribe'));
        }
    }
    else if (request.kind === 'publish') {
        console.log(addr, `Authorizing publisher to ${channel}`);
        // if (request.password === SEND_PASSWORD) {
            return Promise.resolve(getPayload('publish'));
        // }
    }
    else {
        return Promise.reject(Error(addr + ' Unknown kind ' + request.kind));
    }
    return Promise.reject(Error(addr + ' Invalid authorization for ' + request.kind));
}

module.exports = {
    authorize,
};
