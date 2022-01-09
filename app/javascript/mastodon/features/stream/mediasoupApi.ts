import { types as mediasoupTypes } from "mediasoup-client";
import { TransportOptions } from "mediasoup-client/lib/types";
const serverUrl = "http://localhost:4443";

type Request2<Params> = {
  uri: Params extends "" ? string : (p: Params) => string;
  method?: "get" | "post";
};

const createRequest = <Params, Body, Response>(data: Request2<Params>) => {
  return async (params: Params, body: Body) => {
    try {
      const method = data.method ?? "get";
      const res = await fetch(
        serverUrl +
          (typeof data.uri === "function" ? data.uri(params) : data.uri),
        {
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          method,
          body: method !== "get" ? JSON.stringify(body) : undefined,
        }
      );
      return (await res.json()) as Response | undefined;
    } catch (e) {
      console.log({ e });
    }
  };
};

export const createRoom = createRequest<"", {}, { roomId: string }>({
  uri: "/rooms",
  method: "post",
});

export const getRoom = createRequest<
  { roomId: string },
  null,
  mediasoupTypes.RtpCapabilities
>({
  uri: (p) => `/rooms/${p.roomId}`,
});

export const createBroadcaster = createRequest<
  { roomId: string },
  { id: string; displayName: string; device: { name: string } },
  { peers: [] }
>({
  uri: (p) => `/rooms/${p.roomId}/broadcasters`,
  method: "post",
});

type PlainMediaTransport = {
  id: string;
  ip: string;
  port: string;
  rtcpPort: string;
};
type WebRTCMediaTransport = TransportOptions;

type plain = "plain";
type webrtc = "webrtc";
type X<S extends { type: string }> = S["type"] extends plain
  ? PlainMediaTransport
  : WebRTCMediaTransport;

type Z = X<{ type: "webrtc" }>;
export const createMediaTransport = <T extends webrtc>(s: T) =>
  createRequest<
    Record<"roomId" | "broadcaster", string>,
    { type: T; comedia: true; rtcpMux: false },
    X<{ type: T }>
  >({
    uri: (p) => `/rooms/${p.roomId}/broadcasters/${p.broadcaster}/transports`,
    method: "post",
  });

export const createWebRtcTransport = createRequest<
  { room: string },
  {
    forceTcp?: boolean;
    producing: boolean;
    consuming: boolean;
    sctpCapabilities?: mediasoupTypes.SctpCapabilities;
  },
  mediasoupTypes.TransportOptions
>({
  uri: (p) => `/rooms/${p.room}/createWebRtcTransport`,
  method: "post",
});

export const connectWebRtcTransport = createRequest<
  undefined,
  {
    transportId: string;
    dtlsParameters: any;
  },
  undefined
>({
  uri: `/connectWebRtcTransport`,
  method: "post",
});

type VideoCodec = { mimeType: "video/vp8"; payloadType: 101; clockRate: 90000 };
type AudioCodec = {
  mimeType: "audio/opus";
  payloadType: 100;
  clockRate: 48000;
  channels: 2;
  parameters: { "sprop-stereo": 1 };
};
type RTC = {
  codecs: (VideoCodec | AudioCodec)[];
  encodings: [{ ssrc: 1111 | 2222 }];
};

export const getStreamer = createRequest<
  { room: string },
  {transport: string},
  mediasoupTypes.ConsumerOptions
>({
  uri: (p) => `/rooms/${p.room}/streamer`,
  method: 'post'
});

export const createMediasoupProducer = createRequest<
  { roomId: string; broadcasterId: string; transportId: string },
  { kind: "audio" | "video"; rtpParameters: RTC },
  { id: string }
>({
  uri: (p) =>
    `/rooms/${p.roomId}/broadcasters/${p.broadcasterId}/transports/${p.transportId}/producers`,
  method: "post",
});

export const connectBroadcasterTransport = createRequest<
  { room: string; broadcaster: string; transport: string },
  { dtlsParameters: any },
  {}
>({
  uri: (p) =>
    `/rooms/${p.room}/broadcasters/${p.broadcaster}/transports/${p.transport}/connect`,
  method: "post",
});
