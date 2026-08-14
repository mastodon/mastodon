import type React from 'react';
import { useCallback, useRef, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  DotsThreeIcon,
  PencilIcon,
  PlusIcon,
  TrashIcon,
  WaveformIcon,
} from '@phosphor-icons/react';

import { undoUploadCompose } from '@/mastodon/actions/compose';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiAudioAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import { IconButton } from '@/mastodon/components/button/redesign';
import {
  DropdownItemButton,
  DropdownPopover,
} from '@/mastodon/components/dropdown/redesign';
import { Icon } from '@/mastodon/components/icon';
import { useAudioContext } from '@/mastodon/hooks/useAudioContext';
import { useAudioVisualizer } from '@/mastodon/hooks/useAudioVisualizer';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { selectAccountAvatarUrl } from '@/mastodon/selectors/accounts';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { AudioVisualizer } from '../../audio/visualizer';

import classes from './attachments.module.scss';
import type { ComposeAttachment } from './selectors';
import { selectComposeAttachments } from './selectors';

const selectAttachment = createAppSelector(
  [selectComposeAttachments, (_, id?: string) => id],
  (attachments, id) => {
    if (!id) {
      return null;
    }
    return attachments.find((attachment) => attachment.id === id) ?? null;
  },
);

export const ComposeUpload: React.FC<{
  id?: string;
  className?: string;
  single?: boolean;
}> = ({ id, className, single }) => {
  const attachment = useAppSelector((state) => selectAttachment(state, id));
  const sensitive = useAppSelector((state) => !!state.compose.get('spoiler'));
  const [open, { onToggle, onFalse }] = useToggle();
  const [target, setTarget] = useState<HTMLButtonElement | null>(null);

  const dispatch = useAppDispatch();
  const handleEdit = useCallback(() => {
    if (id) {
      dispatch(
        openModal({ modalType: 'FOCAL_POINT', modalProps: { mediaId: id } }),
      );
    }
  }, [dispatch, id]);
  const handleDelete = useCallback(() => {
    if (id) {
      dispatch(undoUploadCompose(id));
    }
  }, [dispatch, id]);

  if (!attachment || attachment.type === 'unknown') {
    return <div className={classNames(classes.mediaUpload, className)} />;
  }

  if (attachment.type === 'audio') {
    return <ComposeAudioUpload attachment={attachment} />;
  }

  let x = 50;
  let y = 50;
  const focusX = attachment.meta.focus?.x;
  const focusY = attachment.meta.focus?.y;
  if (focusX && focusY) {
    x = (focusX / 2 + 0.5) * 100;
    y = (focusY / -2 + 0.5) * 100;
  }

  return (
    <div
      className={classNames(classes.mediaUpload, className)}
      style={{
        backgroundImage:
          !sensitive && attachment.preview_url
            ? `url(${attachment.preview_url})`
            : undefined,
        backgroundPosition: `${x}% ${y}%`,
        aspectRatio: single
          ? `${attachment.meta.original.width} / ${attachment.meta.original.height}`
          : undefined,
      }}
      data-color-scheme='dark'
    >
      {sensitive && attachment.blurhash && (
        <Blurhash hash={attachment.blurhash} className={classes.blurHash} />
      )}

      <IconButton
        icon={DotsThreeIcon}
        size='sm'
        color='neutral'
        className={classes.mediaMenuButton}
        onClick={onToggle}
        ref={setTarget}
      >
        <FormattedMessage
          id='compose.upload.menu'
          defaultMessage='Add alt text or remove the image'
        />
      </IconButton>

      <DropdownPopover
        isOpen={open}
        onClose={onFalse}
        reference={target}
        placement='bottom-end'
        offset={4}
        maxWidth={170}
      >
        <DropdownItemButton
          onClick={handleEdit}
          leadingIcon={attachment.description ? PencilIcon : PlusIcon}
        >
          {attachment.description ? (
            <FormattedMessage
              id='compose.upload.menu.edit_alt'
              defaultMessage='Edit alt text'
            />
          ) : (
            <FormattedMessage
              id='compose.upload.menu.add_alt'
              defaultMessage='Add alt text'
            />
          )}
        </DropdownItemButton>

        <hr />

        <DropdownItemButton
          className={classes.mediaMenuDelete}
          onClick={handleDelete}
          leadingIcon={TrashIcon}
        >
          <FormattedMessage
            id='compose.upload.menu.delete'
            defaultMessage='Remove image'
          />
        </DropdownItemButton>
      </DropdownPopover>

      {attachment.description && (
        <span className={classes.mediaAlt}>
          <FormattedMessage id='compose.upload.alt' defaultMessage='Alt' />
        </span>
      )}
    </div>
  );
};

const ComposeAudioUpload: React.FC<{
  attachment: ComposeAttachment<ApiAudioAttachmentJSON>;
}> = ({ attachment }) => {
  const { id, preview_url } = attachment;
  const userAvatar = useAppSelector(selectAccountAvatarUrl);
  const sensitive = useAppSelector((state) => !!state.compose.get('spoiler'));

  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  const audioElementRef = useRef<HTMLAudioElement>(null);
  const { audioContextRef, sourceRef } = useAudioContext({ audioElementRef });
  const frequencyBands = useAudioVisualizer({
    audioContextRef,
    sourceRef,
    numBands: 3,
  });

  const showAvatar = !preview_url || sensitive;

  return (
    <div
      className={classes.audioWrapper}
      style={{
        backgroundImage: !showAvatar ? `url(${preview_url})` : undefined,
      }}
    >
      <audio src={attachment.url} ref={audioElementRef} hidden />

      <AudioVisualizer
        poster={showAvatar ? userAvatar : undefined}
        frequencyBands={frequencyBands}
      />

      <Icon
        id='waveform'
        icon={WaveformIcon}
        className={classes.audioWaveformIcon}
      />

      <IconButton
        size='sm'
        icon={TrashIcon}
        color='destructive'
        onClick={handleDelete}
        className={classes.mediaMenuButton}
      >
        <FormattedMessage
          id='compose.upload.audio.delete'
          defaultMessage='Remove audio'
        />
      </IconButton>
    </div>
  );
};
