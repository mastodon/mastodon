import { useState, useCallback } from 'react';

import { is } from 'immutable';

import { Blurhash } from 'mastodon/components/blurhash';
import { useBlurhash } from 'mastodon/initial_state';
import type { MediaAttachment } from 'mastodon/models/status';
import { useAppSelector } from 'mastodon/store';

export const EmbeddedStatusThumbnail: React.FC<{
  statusId: string;
  className?: string;
}> = ({ statusId, className }) => {
  const attachment = useAppSelector(
    (state) =>
      state.statuses.getIn([statusId, 'media_attachments', 0]) as
        | MediaAttachment
        | undefined,
    (oldValue, newValue) => is(oldValue, newValue),
  );
  const [loaded, setLoaded] = useState(false);

  const handleLoad = useCallback(() => {
    setLoaded(true);
  }, [setLoaded]);

  if (!attachment) {
    return null;
  }

  const previewUrl = attachment.get('preview_url') as string;
  const blurhash = attachment.get('blurhash') as string;
  const description = (attachment.getIn(['translation', 'description']) ||
    attachment.get('description')) as string;
  const focusX = (attachment.getIn(['meta', 'focus', 'x']) || 0) as number;
  const focusY = (attachment.getIn(['meta', 'focus', 'y']) || 0) as number;
  const x = (focusX / 2 + 0.5) * 100;
  const y = (focusY / -2 + 0.5) * 100;

  return (
    <div className={className}>
      {!loaded && <Blurhash hash={blurhash} dummy={!useBlurhash} />}

      <img
        src={previewUrl}
        alt={description}
        title={description}
        onLoad={handleLoad}
        style={{ objectPosition: `${x}% ${y}%` }}
      />
    </div>
  );
};
