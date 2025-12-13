import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { submitCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  title: {
    id: 'confirmations.missing_alt_text.title',
    defaultMessage: 'Add alt text?',
  },
  confirm: {
    id: 'confirmations.missing_alt_text.confirm',
    defaultMessage: 'Add alt text',
  },
  message: {
    id: 'confirmations.missing_alt_text.message',
    defaultMessage:
      'Your post contains media without alt text. Adding descriptions helps make your content accessible to more people.',
  },
  secondary: {
    id: 'confirmations.missing_alt_text.secondary',
    defaultMessage: 'Post anyway',
  },
});

export const ConfirmMissingAltTextModal: React.FC<
  BaseConfirmationModalProps
> = ({ onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const mediaId = useAppSelector(
    (state) =>
      (
        (state.compose as ImmutableMap<string, unknown>).get(
          'media_attachments',
        ) as ImmutableList<MediaAttachment>
      )
        .find(
          (media) =>
            ['image', 'gifv'].includes(media.get('type') as string) &&
            ((media.get('description') ?? '') as string).length === 0,
        )
        ?.get('id') as string,
  );

  const handleConfirm = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'FOCAL_POINT',
        modalProps: {
          mediaId,
        },
      }),
    );
  }, [dispatch, mediaId]);

  const handleSecondary = useCallback(() => {
    dispatch(submitCompose());
  }, [dispatch]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.title)}
      message={intl.formatMessage(messages.message)}
      confirm={intl.formatMessage(messages.confirm)}
      secondary={intl.formatMessage(messages.secondary)}
      onConfirm={handleConfirm}
      onSecondary={handleSecondary}
      onClose={onClose}
    />
  );
};
