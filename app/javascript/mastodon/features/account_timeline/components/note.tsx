import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { fetchRelationships } from '@/mastodon/actions/accounts';
import { openModal } from '@/mastodon/actions/modal';
import { Callout } from '@/mastodon/components/callout';
import { IconButton } from '@/mastodon/components/icon_button';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import EditIcon from '@/material-icons/400-24px/edit_square.svg?react';

import classes from './redesign.module.scss';

const messages = defineMessages({
  title: {
    id: 'account.note.title',
    defaultMessage: 'Personal note (visible only to you)',
  },
  editButton: {
    id: 'account.note.edit_button',
    defaultMessage: 'Edit',
  },
});

export const AccountNote: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  const handleEdit = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_NOTE',
        modalProps: { accountId },
      }),
    );
  }, [accountId, dispatch]);

  if (!relationship?.note) {
    return null;
  }

  return (
    <Callout
      icon={false}
      title={intl.formatMessage(messages.title)}
      className={classes.note}
      extraContent={
        <IconButton
          icon='edit'
          iconComponent={EditIcon}
          title={intl.formatMessage(messages.editButton)}
          className={classes.noteEditButton}
          onClick={handleEdit}
        />
      }
    >
      <div className={classes.noteContent}>{relationship.note}</div>
    </Callout>
  );
};
