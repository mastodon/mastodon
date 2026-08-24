import type React from 'react';
import { useCallback, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  ImageSquareIcon,
  ChartBarHorizontalIcon,
  WarningCircleIcon,
} from '@phosphor-icons/react';

import { addPoll, uploadCompose } from '@/mastodon/actions/compose';
import { Button, IconButton } from '@/mastodon/components/button/redesign';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import type { OnEmojiPick } from './emoji';
import { ComposeEmojiButton } from './emoji';
import {
  selectComposeAttachments,
  selectComposeCanSubmit,
  selectComposeCharsCount,
  selectComposeHasAttachments,
  selectComposeType,
} from './selectors';
import classes from './styles.module.scss';

export const ComposeFooter: React.FC<{ onEmojiPick: OnEmojiPick }> = ({
  onEmojiPick,
}) => {
  const type = useAppSelector(selectComposeType);
  const { current, max } = useAppSelector(selectComposeCharsCount);
  const { hasPoll, quotedStatusId } = useAppSelector(
    selectComposeHasAttachments,
  );
  const hasQuote = !!quotedStatusId;
  const isSubmitting = useAppSelector(
    (state) => !!state.compose.get('is_submitting'),
  );
  const canSubmit = useAppSelector(selectComposeCanSubmit);

  const dispatch = useAppDispatch();
  const handlePoll = useCallback(() => {
    dispatch(addPoll());
  }, [dispatch]);

  return (
    <footer className={classes.footer}>
      <ComposeUploadButton disabled={hasQuote} />

      <ComposeEmojiButton onPick={onEmojiPick} />

      <IconButton
        size='sm'
        icon={ChartBarHorizontalIcon}
        disabled={hasQuote || hasPoll}
        onClick={handlePoll}
      >
        <FormattedMessage
          id='poll_button.add_poll'
          defaultMessage='Add a poll'
        />
      </IconButton>

      <div className={classes.flexGrowWrap}>
        <span
          className={classNames(
            classes.counter,
            current > max && classes.counterError,
          )}
        >
          {current > max && <WarningCircleIcon weight='fill' />}
          <FormattedMessage
            id='compose.counter'
            defaultMessage='{current, number}/{max, number}'
            values={{ current, max }}
          />
        </span>

        <Button
          variant='solid'
          type='submit'
          disabled={!canSubmit}
          loading={isSubmitting}
        >
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
      </div>
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
    fileTypesList,
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
    const hasImages = attachments.some(
      (attachment) => attachment.type === 'image' || attachment.type === 'gifv',
    );
    const fileTypes = (fileTypesList?.toArray() ?? []).filter(
      (fileType) => !hasImages || fileType.startsWith('image/'),
    );
    return {
      accepted: fileTypes.join(','),
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
