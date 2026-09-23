import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import { useStatusIcons } from '@/mastodon/components/status/hooks';
import { BoostButton } from '@/mastodon/components/status/legacy/boost_button';
import OpenInNewIcon from '@/material-icons/400-24px/open_in_new.svg?react';
import { replyCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { IconButton } from 'mastodon/components/icon_button';
import { useIdentity } from 'mastodon/identity_context';
import type { Account } from 'mastodon/models/account';
import type { Status } from 'mastodon/models/status';
import { makeGetStatus } from 'mastodon/selectors';
import type { RootState } from 'mastodon/store';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
});

type GetStatusSelector = (
  state: RootState,
  props: { id?: string | null; contextType?: string },
) => Status | null;

export const Footer: React.FC<{
  statusId: string;
  withOpenButton?: boolean;
  onClose: (arg0?: boolean) => void;
}> = ({ statusId, withOpenButton, onClose }) => {
  const { signedIn } = useIdentity();
  const intl = useIntl();
  const history = useHistory();
  const dispatch = useAppDispatch();
  const getStatus = useMemo(() => makeGetStatus(), []) as GetStatusSelector;
  const status = useAppSelector((state) => getStatus(state, { id: statusId }));
  const account = status?.get('account') as Account | undefined;
  const askReplyConfirmation = useAppSelector(
    (state) => (state.compose.get('text') as string).trim().length !== 0,
  );

  const handleReplyClick = useCallback(() => {
    if (!status) {
      return;
    }

    if (signedIn) {
      onClose(true);

      if (askReplyConfirmation) {
        dispatch(
          openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }),
        );
      } else {
        dispatch(replyCompose(status));
      }
    } else {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            intent: 'reply',
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [dispatch, status, signedIn, askReplyConfirmation, onClose]);

  const handleOpenClick = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0 || !status) {
        return;
      }

      onClose();

      history.push(`/@${account?.acct}/${status.get('id') as string}`);
    },
    [history, status, account, onClose],
  );

  const { reply, like } = useStatusIcons(statusId);

  if (!status) {
    return null;
  }

  return (
    <div className='picture-in-picture__footer'>
      <IconButton
        className='status__action-bar-button'
        title={reply.title}
        active={reply.active}
        icon='reply'
        iconComponent={reply.icon}
        onClick={handleReplyClick}
        counter={reply.counter}
      />

      <BoostButton counters statusId={statusId} />

      <IconButton
        className='status__action-bar-button star-icon'
        animate
        active={like.active}
        title={like.title}
        icon='star'
        iconComponent={like.icon}
        onClick={like.action}
        counter={like.counter}
      />

      {withOpenButton && (
        <IconButton
          className='status__action-bar-button'
          title={intl.formatMessage(messages.open)}
          icon='external-link'
          iconComponent={OpenInNewIcon}
          onClick={handleOpenClick}
          href={`/@${account?.acct}/${status.get('id') as string}`}
        />
      )}
    </div>
  );
};
