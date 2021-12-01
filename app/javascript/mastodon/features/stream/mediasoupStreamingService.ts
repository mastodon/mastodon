import protooClient from "protoo-client";
import randomString from "random-string";
import * as mediasoupClient from "mediasoup-client";
import * as mediasoupApi from "./mediasoupApi";

const PC_PROPRIETARY_CONSTRAINTS = {
  optional: [{ googDscp: true }],
};

export type ProtoRequest = "createStreamingRoom";
const mediasoupUrl = "localhost:4443";
export function getMediasoupServerAPI() {
  const createStreamingRoom = async (
    sctpCapabilities: mediasoupClient.types.SctpCapabilities
  ) => {
    const res = await fetch(`${mediasoupUrl}/createStreamingRoom`, {
      method: "post",
      body: JSON.stringify({ sctpCapabilities }),
    });
    return (await res.json()) as {
      room: string;
      routerRtpCapabilities: mediasoupClient.types.RtpCapabilities;
      transportOptions: mediasoupClient.types.TransportOptions;
    };
  };

  return { createStreamingRoom };
}

export function getProtooClient(roomId = randomString({ length: 8 })) {
  const protooTransport = new protooClient.WebSocketTransport(
    `ws://${mediasoupUrl}?roomId=${roomId}&peerId=streamer`
  );
}

export async function getSendTransport() {
  const mediasoupDevice = new mediasoupClient.Device({
    handlerName: "Chrome74",
  });

  await mediasoupApi.createBroadcaster(
    { roomId: "streaming" },
    { device: { name: "web" }, displayName: "streamer", id: "streamer" }
  );

  const s = await mediasoupApi.createMediaTransport("webrtc")(
    { roomId: "streaming", broadcaster: "streamer" },
    {
      type: "webrtc",
      comedia: false as any,
      rtcpMux: false,
    }
  );

  // const s = await mediasoupApi.createWebRtcTransport(
  //   { room: "streaming" },
  //   { producing: true, consuming: false }
  // );

  // const { room, routerRtpCapabilities, transportOptions } =
  //   await getMediasoupServerAPI().createStreamingRoom(
  //     mediasoupDevice.sctpCapabilities
  //   );

  const routerRtpCapabilities = await mediasoupApi.getRoom(
    {
      roomId: "streaming",
    },
    null
  );

  await mediasoupDevice.load({ routerRtpCapabilities });

  const { id, iceParameters, iceCandidates, dtlsParameters, sctpParameters } =
    s;

  const transport = mediasoupDevice.createSendTransport({
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters: {
      ...dtlsParameters,
      // Remote DTLS role. We know it's always 'auto' by default so, if
      // we want, we can force local WebRTC transport to be 'client' by
      // indicating 'server' here and vice-versa.
      role: "auto",
    },
    iceServers: [],
    proprietaryConstraints: PC_PROPRIETARY_CONSTRAINTS,
    // additionalSettings: {
    //   encodedInsertableStreams: this._e2eKey && e2e.isSupported(),
    // },
  });
  const producer = await mediasoupApi.createMediasoupProducer(
    {
      roomId: "streaming",
      broadcasterId: "streamer",
      transportId: transport.id,
    },
    {
      kind: "video",
      rtpParameters: {
        codecs: [{ mimeType: "video/vp8", clockRate: 90000, payloadType: 101 }],
        encodings: [{ ssrc: 2222 }],
      },
    }
  );
  return transport;
}

export const getReceiveTransport = async () => {
  const mediasoupDevice = new mediasoupClient.Device({
    handlerName: "Chrome74",
  });

  const s = await mediasoupApi.createWebRtcTransport(
    { room: "streaming" },
    { consuming: true, producing: false }
  );

  const routerRtpCapabilities = await mediasoupApi.getRoom(
    {
      roomId: "streaming",
    },
    null
  );

  await mediasoupDevice.load({ routerRtpCapabilities });

  const { id, iceParameters, iceCandidates, dtlsParameters, sctpParameters } =
    s;

  const transport = mediasoupDevice.createRecvTransport({
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters: {
      ...dtlsParameters,
      // Remote DTLS role. We know it's always 'auto' by default so, if
      // we want, we can force local WebRTC transport to be 'client' by
      // indicating 'server' here and vice-versa.
      role: "auto",
    },
    iceServers: [],
    proprietaryConstraints: PC_PROPRIETARY_CONSTRAINTS,
    // additionalSettings: {
    //   encodedInsertableStreams: this._e2eKey && e2e.isSupported(),
    // },
  });
  // (await transport.consume({ rtpParameters })).track;
  return transport;
};

export const getVideoTrace = async () => {
  const recvTransport = await getReceiveTransport();
  recvTransport.on(
    "connect",
    (
      { dtlsParameters },
      callback,
      errback // eslint-disable-line no-shadow
    ) => {
      mediasoupApi
        .connectWebRtcTransport(undefined, {
          transportId: recvTransport.id,
          dtlsParameters,
        })
        .then(callback)
        .catch(errback);
    }
  );
};
