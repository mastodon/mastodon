import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { PencilSimpleIcon } from '@phosphor-icons/react';

import { fetchRelationships } from '@/mastodon/actions/accounts';
import { openModal } from '@/mastodon/actions/modal';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { IconButton } from '../button';
import { Callout } from '../callout';

import classes from './styles.module.scss';

const messages = defineMessages({
  title: {
    id: 'account.note.title',
    defaultMessage: 'Personal note (visible only to you)',
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
          size='sm'
          icon={PencilSimpleIcon}
          className={classes.noteEditButton}
          onClick={handleEdit}
        >
          <FormattedMessage
            id='account.note.edit_button'
            defaultMessage='Edit'
          />
        </IconButton>
      }
    >
      <div className={classes.noteContent}>{relationship.note}</div>
    </Callout>
  );
};
