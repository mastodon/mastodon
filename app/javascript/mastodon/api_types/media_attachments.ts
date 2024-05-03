// See app/serializers/rest/media_attachment_serializer.rb

export type MediaAttachmentType =
  | 'image'
  | 'gifv'
  | 'video'
  | 'unknown'
  | 'audio';

export interface ApiMediaAttachmentJSON {
  id: string;
  type: MediaAttachmentType;
  url: string;
  preview_url: string;
  remoteUrl: string;
  preview_remote_url: string;
  text_url: string;
  // TODO: how to define this?
  meta: unknown;
  description?: string;
  blurhash: string;
}
