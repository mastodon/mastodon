interface MediaAttachmentMetaImageInfoRawValues {
  width: number;
  height: number;
  size: string;
  aspect: number;
}

interface MediaAttachmentImageMetaRawValues {
  original: MediaAttachmentMetaImageInfoRawValues;
  small: MediaAttachmentMetaImageInfoRawValues;
}

interface MediaAttachmentImageRawValues {
  id: string;
  type: 'image';
  url: string;
  preview_url: string;
  remote_url: string | null;
  preview_remote_url: string | null;
  text_url: string | null;
  meta: MediaAttachmentImageMetaRawValues;
  description: string | null;
  blurhash: string;
}

interface MediaAttachmentMetaVideoInfoRawValues {
  width: number;
  height: number;
  frame_rate: string;
  duration: number;
  bitrate: number;
}

interface MediaAttachmentVideoMetaRawValues {
  length: string;
  duration: number;
  fps: number;
  size: string;
  width: number;
  height: number;
  aspect: number;
  audio_encode: string;
  audio_bitrate: string;
  audio_channels: string;
  original: MediaAttachmentMetaVideoInfoRawValues;
  small: MediaAttachmentImageMetaRawValues;
}

interface MediaAttachmentVideoRawValues {
  id: string;
  type: 'video';
  url: string;
  preview_url: string;
  remote_url: string | null;
  text_url: string;
  meta: MediaAttachmentVideoMetaRawValues;
  description: string | null;
  blurhash: string;
}

interface MediaAttachmentGIFVMetaRawValues {
  length: string;
  duration: number;
  fps: number;
  size: string;
  width: number;
  height: number;
  aspect: number;
  original: MediaAttachmentMetaVideoInfoRawValues;
  small: MediaAttachmentMetaImageInfoRawValues;
}

interface MediaAttachmentGIFVRawValues {
  id: string;
  type: 'gifv';
  url: string;
  preview_url: string;
  remote_url: string | null;
  text_url: string;
  meta: MediaAttachmentGIFVMetaRawValues;
  description: string | null;
  blurhash: string;
}

export type MediaAttachmentRawValues =
  | MediaAttachmentImageRawValues
  | MediaAttachmentVideoRawValues
  | MediaAttachmentGIFVRawValues;
