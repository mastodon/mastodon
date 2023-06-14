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

export type MediaAttachmentRawValues = MediaAttachmentImageRawValues;
