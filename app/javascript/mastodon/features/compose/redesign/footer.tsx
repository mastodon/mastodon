import type React from 'react';
import { useCallback, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  ImageSquareIcon,
  SmileyIcon,
  ChartBarHorizontalIcon,
} from '@phosphor-icons/react';

import { uploadCompose } from '@/mastodon/actions/compose';
import { Button, IconButton } from '@/mastodon/components/button/redesign';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import {
  selectComposeAttachments,
  selectComposeCharsCount,
  selectComposeType,
} from './selectors';
import classes from './styles.module.scss';

export const ComposeFooter: React.FC = () => {
  const type = useAppSelector(selectComposeType);
  const { current, max } = useAppSelector(selectComposeCharsCount);
  const hasQuote = useAppSelector(
    (state) => !!state.compose.get('quoted_status_id'),
  );

  return (
    <footer className={classes.footer}>
      <ComposeUploadButton disabled={hasQuote} />

      <IconButton size='sm' icon={SmileyIcon}>
        <FormattedMessage
          id='emoji_button.label'
          defaultMessage='Insert emoji'
        />
      </IconButton>
      <IconButton size='sm' icon={ChartBarHorizontalIcon} disabled={hasQuote}>
        <FormattedMessage
          id='poll_button.add_poll'
          defaultMessage='Add a poll'
        />
      </IconButton>
      <span className={classes.counter}>
        <FormattedMessage
          id='compose.counter'
          defaultMessage='{current, number}/{max, number}'
          values={{ current, max }}
        />
      </span>
      <Button color='neutral'>
        {type !== 'message' && (
          <FormattedMessage id='compose.publish' defaultMessage='Publish' />
        )}
        {type === 'message' && (
          <FormattedMessage
            id='compose.message.publish'
            defaultMessage='Send'
          />
        )}
      </Button>
    </footer>
  );
};

const selectUpload = createAppSelector(
  [
    (state) =>
      state.media_attachments.get('accept_content_types') as
        | Immutable.List<string>
        | undefined,
    (state) => !!state.compose.get('is_uploading'),
    selectComposeAttachments,
    (state) => state.compose.get('pending_media_attachments') as number,
    (state) =>
      state.server.server.item?.configuration.statuses.max_media_attachments ??
      4,
    (state) => state.compose.get('resetFileKey') as number,
  ],
  (
    fileTypes,
    isUploading,
    attachments,
    pendingAttachments,
    maxAttachments,
    resetFileKey,
  ) => {
    const hasVideoOrAudio = attachments.some(
      (attachment) =>
        attachment.type === 'audio' || attachment.type === 'video',
    );
    return {
      accepted: (fileTypes?.toArray() ?? []).join(','),
      loading: isUploading || pendingAttachments > 0,
      disabled:
        attachments.length + pendingAttachments >= maxAttachments ||
        hasVideoOrAudio,
      resetFileKey,
    };
  },
);

const ComposeUploadButton: React.FC<{ disabled?: boolean }> = ({
  disabled: disabledProp,
}) => {
  const { accepted, disabled, loading, resetFileKey } =
    useAppSelector(selectUpload);

  const ref = useRef<HTMLInputElement>(null);
  const handleClick = useCallback(() => {
    ref.current?.click();
  }, []);

  const dispatch = useAppDispatch();
  const handleChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const files = event.target.files;
      if (files?.length) {
        dispatch(uploadCompose(files));
      }
    },
    [dispatch],
  );

  return (
    <>
      <IconButton
        size='sm'
        icon={ImageSquareIcon}
        disabled={disabled || disabledProp}
        loading={loading}
        onClick={handleClick}
      >
        <FormattedMessage
          id='upload_button.label'
          defaultMessage='Add images, a video or an audio file'
        />
      </IconButton>
      <input
        hidden
        ref={ref}
        type='file'
        multiple
        accept={accepted}
        disabled={disabled}
        key={resetFileKey}
        onChange={handleChange}
      />
    </>
  );
};
