import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  ArrowsLeftRightIcon,
  EyeSlashIcon,
  PencilSimpleIcon,
  PlusIcon,
  TrashIcon,
} from '@phosphor-icons/react';

import {
  changeComposeSensitivity,
  undoUploadCompose,
} from '@/mastodon/actions/compose';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiAudioAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import { Button, IconButton } from '@/mastodon/components/button';
import { StatusImage } from '@/mastodon/components/status/image';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './attachments.module.scss';
import type { ComposeAttachment } from './selectors';
import { selectComposeAttachment, selectComposeSensitive } from './selectors';

export const ComposeUpload: React.FC<
  {
    id?: string;
    single?: boolean;
    showSensitive?: boolean;
  } & React.ComponentPropsWithRef<'div'>
> = ({ id, className, single, showSensitive = single, ...props }) => {
  const attachment = useAppSelector((state) =>
    selectComposeAttachment(state, id),
  );

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

  const { mediaSensitive, sensitive } = useAppSelector(selectComposeSensitive);
  const handleToggleSensitive = useCallback(() => {
    dispatch(changeComposeSensitivity());
  }, [dispatch]);

  if (!attachment || attachment.type === 'unknown') {
    return <div className={classNames(classes.mediaUpload, className)} />;
  }

  if (attachment.type === 'audio') {
    return <ComposeAudioUpload attachment={attachment} />;
  }

  return (
    <StatusImage attachment={attachment} sensitive={mediaSensitive} {...props}>
      <Button
        size='xs'
        color='media'
        variant={attachment.description ? 'tonal' : 'solid'}
        onClick={handleAltEdit}
        className={classes.mediaMenuAltButton}
        leadingIcon={attachment.description ? PencilSimpleIcon : PlusIcon}
        tooltip={{
          type: 'label',
          text: attachment.description ? (
            <FormattedMessage
              id='account_edit.image_alt_modal.edit_title'
              defaultMessage='Edit alt text'
            />
          ) : (
            <FormattedMessage
              id='account_edit.image_alt_modal.add_title'
              defaultMessage='Add alt text'
            />
          ),
          placement: 'top',
        }}
      >
        <span aria-hidden='true'>
          <FormattedMessage id='alt_text_badge.label' defaultMessage='ALT' />
        </span>
      </Button>

      <div className={classes.mediaMenuButtons}>
        {showSensitive && !sensitive && (
          <IconButton
            onClick={handleToggleSensitive}
            icon={EyeSlashIcon}
            size='xs'
            color='media'
            tooltipPlacement='top'
          >
            <FormattedMessage
              id='compose.sensitive.blur'
              defaultMessage='Blur all media'
            />
          </IconButton>
        )}
        {!single && (
          <IconButton
            onClick={handleRearrange}
            icon={ArrowsLeftRightIcon}
            size='xs'
            color='media'
            tooltipPlacement='top'
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
          size='xs'
          color='media'
          tooltipPlacement='top'
        >
          <FormattedMessage
            id='compose.upload.menu.delete'
            defaultMessage='Remove image'
          />
        </IconButton>
      </div>
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
