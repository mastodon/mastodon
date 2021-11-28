import protooClient from 'protoo-client';
import randomString from 'random-string';
import * as mediasoupClient from 'mediasoup-client';

const PC_PROPRIETARY_CONSTRAINTS = {
  optional: [{ googDscp: true }],
};

export function getProtooClient(roomId = randomString({ length: 8 })) {
  const protooTransport = new protooClient.WebSocketTransport(
    `wss://localhost:4443/?roomId=${roomId}&peerId=streamer`,
  );

  return new protooClient.Peer(protooTransport);
}

export async function getSendTransport(protooClient: protooClient.Peer) {
  const mediasoupDevice = new mediasoupClient.Device({
    handlerName: 'Chrome74',
  });

  const routerRtpCapabilities = await protooClient.request(
    'getRouterRtpCapabilities',
  );

  await mediasoupDevice.load({ routerRtpCapabilities });

  const transportInfo = await protooClient.request('createWebRtcTransport', {
    forceTcp: this._forceTcp,
    producing: true,
    consuming: false,
    sctpCapabilities: this._useDataChannel
      ? mediasoupDevice.sctpCapabilities
      : undefined,
  });

  const { id, iceParameters, iceCandidates, dtlsParameters, sctpParameters } =
    transportInfo;

  return mediasoupDevice.createSendTransport({
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters: {
      ...dtlsParameters,
      // Remote DTLS role. We know it's always 'auto' by default so, if
      // we want, we can force local WebRTC transport to be 'client' by
      // indicating 'server' here and vice-versa.
      role: 'auto',
    },
    sctpParameters,
    iceServers: [],
    proprietaryConstraints: PC_PROPRIETARY_CONSTRAINTS,
    // additionalSettings: {
    //   encodedInsertableStreams: this._e2eKey && e2e.isSupported(),
    // },
  });
}
