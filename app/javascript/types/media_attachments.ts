import type { Record } from 'immutable';

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

interface MediaAttachmentMetaAudioInfoRawValues {
  duration: number;
  bitrate: number;
}

interface MediaAttachmentAudioMetaRawValues {
  length: string;
  duration: number;
  audio_encode: string;
  audio_bitrate: string;
  audio_channels: string;
  original: MediaAttachmentMetaAudioInfoRawValues;
}

interface MediaAttachmentAudioRawValues {
  id: string;
  type: 'audio';
  url: string;
  preview_url: string;
  remote_url: string | null;
  text_url: string;
  meta: MediaAttachmentAudioMetaRawValues;
  description: string | null;
  blurhash: null;
}

export type MediaAttachmentRawValues =
  | MediaAttachmentImageRawValues
  | MediaAttachmentVideoRawValues
  | MediaAttachmentGIFVRawValues
  | MediaAttachmentAudioRawValues;

type MediaAttachmentImage = Record<
  Exclude<MediaAttachmentImageRawValues, 'meta'> & {
    meta: Record<{
      original: Record<MediaAttachmentMetaImageInfoRawValues>;
      small: Record<MediaAttachmentMetaImageInfoRawValues>;
    }>;
  }
>;

type MediaAttachmentVideo = Record<
  Exclude<MediaAttachmentVideoRawValues, 'meta'> & {
    meta: Record<
      Exclude<MediaAttachmentVideoMetaRawValues, 'original' | 'small'> & {
        original: Record<MediaAttachmentMetaVideoInfoRawValues>;
        small: Record<MediaAttachmentImageMetaRawValues>;
      }
    >;
  }
>;

type MediaAttachmentGIFV = Record<
  Exclude<MediaAttachmentGIFVRawValues, 'meta'> & {
    meta: Record<
      Exclude<MediaAttachmentGIFVMetaRawValues, 'original' | 'small'> & {
        original: Record<MediaAttachmentMetaVideoInfoRawValues>;
        small: Record<MediaAttachmentImageMetaRawValues>;
      }
    >;
  }
>;

type MediaAttachmentAudio = Record<
  Exclude<MediaAttachmentAudioRawValues, 'meta'> & {
    meta: Record<
      Exclude<MediaAttachmentAudioMetaRawValues, 'original'> & {
        original: Record<MediaAttachmentMetaAudioInfoRawValues>;
      }
    >;
  }
>;

export type MediaAttachment =
  | MediaAttachmentImage
  | MediaAttachmentVideo
  | MediaAttachmentGIFV
  | MediaAttachmentAudio;
