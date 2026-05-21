import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { domain } from '@/mastodon/initial_state';
import { patchProfile } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  title: {
    id: 'confirmations.hide_featured_tab.title',
    defaultMessage: 'Hide "Featured" tab?',
  },
  intro: {
    id: 'confirmations.hide_featured_tab.intro',
    defaultMessage:
      'You can change this at any time under <i>Edit profile > Profile tab settings</i>.',
  },
  message: {
    id: 'confirmations.hide_featured_tab.message',
    defaultMessage:
      'This will hide the tab for users on {serverName} and other servers running the latest version of Mastodon. Other displays may vary.',
  },
  confirm: {
    id: 'confirmations.hide_featured_tab.confirm',
    defaultMessage: 'Hide tab',
  },
});

export const ConfirmHideFeaturedTabModal: React.FC<
  BaseConfirmationModalProps
> = ({ onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const currentAccountId = useCurrentAccountId();
  const { acct: currentUserName } = useAccount(currentAccountId) ?? {};

  const onConfirm = useCallback(() => {
    void dispatch(patchProfile({ show_featured: false }));
    history.push(`/@${currentUserName}`);
  }, [currentUserName, dispatch, history]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.title)}
      extraContent={
        <div className='prose'>
          <p>
            {intl.formatMessage(messages.intro, {
              i: (words) => <i>{words}</i>,
            })}
          </p>
          <p>
            {intl.formatMessage(messages.message, {
              serverName: domain,
            })}
          </p>
        </div>
      }
      confirm={intl.formatMessage(messages.confirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
