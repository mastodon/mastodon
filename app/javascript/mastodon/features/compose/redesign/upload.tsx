import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { DotsThreeIcon, TrashIcon } from '@phosphor-icons/react';

import { undoUploadCompose } from '@/mastodon/actions/compose';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiAudioAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import { IconButton } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuTrigger,
  MenuItem,
  MenuItemDivider,
  MenuList,
} from '@/mastodon/components/menu';
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

      <Menu>
        <MenuTrigger
          as={IconButton}
          icon={DotsThreeIcon}
          size='sm'
          variant='solid'
          className={classes.mediaMenuButton}
        >
          <FormattedMessage
            id='compose.upload.menu'
            defaultMessage='Add alt text or remove the image'
          />
        </MenuTrigger>

        <ComposeUploadMenu attachment={attachment} single={single} />
      </Menu>

      {attachment.description && (
        <span className={classes.mediaAlt}>
          <FormattedMessage id='compose.upload.alt' defaultMessage='Alt' />
        </span>
      )}
    </div>
  );
};

const ComposeUploadMenu: React.FC<{
  attachment: ComposeAttachment;
  single?: boolean;
}> = ({ attachment, single }) => {
  const dispatch = useAppDispatch();
  const id = attachment.id;

  const handleEdit = useCallback(() => {
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

  return (
    <MenuList placement='bottom-end' offset={4} maxWidth={170}>
      <MenuItem onClick={handleEdit}>
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
      </MenuItem>

      {!single && (
        <MenuItem onClick={handleRearrange}>
          <FormattedMessage
            id='compose.upload.menu.rearrange'
            defaultMessage='Rearrange…'
          />
        </MenuItem>
      )}

      <MenuItemDivider />

      <MenuItem
        className={classes.mediaMenuDelete}
        onClick={handleDelete}
        icon={TrashIcon}
      >
        <FormattedMessage
          id='compose.upload.menu.delete'
          defaultMessage='Remove image'
        />
      </MenuItem>
    </MenuList>
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
