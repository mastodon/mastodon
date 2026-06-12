// See app/serializers/rest/media_attachment_serializer.rb

export type MediaAttachmentType =
  | 'image'
  | 'gifv'
  | 'video'
  | 'unknown'
  | 'audio';

interface BaseApiMediaAttachmentJSON {
  id: string;
  type: MediaAttachmentType;
  url: string;
  preview_url: string;
  remote_url?: string;
  preview_remote_url?: string;
  text_url?: string;
  description?: string;
  blurhash: string;
}

interface ApiImageAttachmentJSON extends BaseApiMediaAttachmentJSON {
  type: 'image';
  meta: {
    original: ApiImageAttachmentMetaJSON;
    small: ApiImageAttachmentMetaJSON;
  };
}

interface ApiAudioAttachmentJSON extends BaseApiMediaAttachmentJSON {
  type: 'audio';
  meta: {
    colors: ApiColorsAttachmentMetaJSON;
    original: ApiVideoAttachmentMetaJSON;
    small: ApiImageAttachmentMetaJSON;
  };
}

interface ApiVideoAttachmentJSON extends BaseApiMediaAttachmentJSON {
  type: 'video';
  meta: {
    colors: ApiColorsAttachmentMetaJSON;
    original: ApiVideoAttachmentMetaJSON;
    small: ApiImageAttachmentMetaJSON;
    focus: {
      x: number;
      y: number;
    };
  };
}

interface ApiGifvAttachmentJSON extends BaseApiMediaAttachmentJSON {
  type: 'gifv';
  meta: {
    original: ApiVideoAttachmentMetaJSON;
    small: ApiImageAttachmentMetaJSON;
  };
}

interface ApiUnknownAttachmentJSON extends BaseApiMediaAttachmentJSON {
  type: 'unknown';
  meta: unknown;
}

export type ApiMediaAttachmentJSON =
  | ApiImageAttachmentJSON
  | ApiAudioAttachmentJSON
  | ApiVideoAttachmentJSON
  | ApiGifvAttachmentJSON
  | ApiUnknownAttachmentJSON;

export interface ApiImageAttachmentMetaJSON {
  width: number;
  height: number;
  size: string;
  aspect: number;
}

export interface ApiVideoAttachmentMetaJSON {
  width: number;
  height: number;
  frame_rate: string;
  duration: number;
  bitrate: number;
}

export interface ApiColorsAttachmentMetaJSON {
  background: string;
  foreground: string;
  accent: string;
}
