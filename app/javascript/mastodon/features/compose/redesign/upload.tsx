import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  ArrowsLeftRightIcon,
  PencilSimpleIcon,
  PlusIcon,
  TrashIcon,
} from '@phosphor-icons/react';

import { undoUploadCompose } from '@/mastodon/actions/compose';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiAudioAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { StatusImage } from '@/mastodon/components/status/image';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './attachments.module.scss';
import type { ComposeAttachment } from './selectors';
import { selectComposeAttachment } from './selectors';

export const ComposeUpload: React.FC<{
  id?: string;
  className?: string;
  single?: boolean;
}> = ({ id, className, single }) => {
  const attachment = useAppSelector((state) =>
    selectComposeAttachment(state, id),
  );
  const sensitive = useAppSelector((state) => !!state.compose.get('spoiler'));

  const dispatch = useAppDispatch();
  const handleAltEdit = useCallback(() => {
    dispatch(
      openModal({ modalType: 'FOCAL_POINT', modalProps: { mediaId: id } }),
    );
  }, [dispatch, id]);
  const handleRearrange = useCallback(() => {
    dispatch(openModal({ modalType: 'COMPOSER_REARRANGE', modalProps: {} }));
  }, [dispatch]);
  const handleDelete = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  if (!attachment || attachment.type === 'unknown') {
    return <div className={classNames(classes.mediaUpload, className)} />;
  }

  if (attachment.type === 'audio') {
    return <ComposeAudioUpload attachment={attachment} />;
  }

  return (
    <StatusImage
      attachment={attachment}
      className={classNames(className, classes.mediaUpload)}
      sensitive={sensitive}
    >
      {sensitive && attachment.blurhash && (
        <Blurhash hash={attachment.blurhash} className={classes.blurHash} />
      )}

      <div className={classes.mediaMenuButtons}>
        {!single && (
          <IconButton
            onClick={handleRearrange}
            icon={ArrowsLeftRightIcon}
            size='sm'
            variant='solid'
          >
            <FormattedMessage
              id='compose.upload.rearrange'
              defaultMessage='Rearrange images'
            />
          </IconButton>
        )}
        <IconButton
          onClick={handleDelete}
          icon={TrashIcon}
          size='sm'
          variant='solid'
        >
          <FormattedMessage
            id='compose.upload.menu.delete'
            defaultMessage='Remove image'
          />
        </IconButton>
      </div>

      <Button
        size='sm'
        variant='solid'
        onClick={handleAltEdit}
        className={classes.mediaMenuAltButton}
        leadingIcon={attachment.description ? PencilSimpleIcon : PlusIcon}
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
      </Button>
    </StatusImage>
  );
};

const ComposeAudioUpload: React.FC<{
  attachment: ComposeAttachment<ApiAudioAttachmentJSON>;
}> = ({ attachment }) => {
  const { id, preview_url } = attachment;
  const sensitive = useAppSelector((state) => !!state.compose.get('spoiler'));

  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  return (
    <div className={classes.audioWrapper}>
      {!sensitive && preview_url && (
        <img src={preview_url} alt='' className={classes.audioCover} />
      )}

      <audio
        src={attachment.url}
        controls
        className={classes.audioControl}
        controlsList='nodownload noplaybackrate'
      />

      <IconButton
        size='md'
        variant='ghost'
        icon={TrashIcon}
        color='destructive'
        onClick={handleDelete}
      >
        <FormattedMessage
          id='compose.upload.audio.delete'
          defaultMessage='Remove audio'
        />
      </IconButton>
    </div>
  );
};
