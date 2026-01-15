import { useCallback } from 'react';

import { useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';

import { AccountBio } from '@/mastodon/components/account_bio';
import { AccountFields } from '@/mastodon/components/account_fields';
import { DisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { Avatar } from 'mastodon/components/avatar';
import { FormattedDateWrapper } from 'mastodon/components/formatted_date';
import { Icon } from 'mastodon/components/icon';
import { AccountNote } from 'mastodon/features/account/components/account_note';
import { DomainPill } from 'mastodon/features/account/components/domain_pill';
import FollowRequestNoteContainer from 'mastodon/features/account/containers/follow_request_note_container';
import { autoPlayGif, me, domain as localDomain } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { isRedesignEnabled } from '../common';

import { AccountBadges } from './badges';
import { AccountButtons } from './buttons';
import { FamiliarFollowers } from './familiar_followers';
import { AccountInfo } from './info';
import { MemorialNote } from './memorial_note';
import { MovedNote } from './moved_note';
import { AccountNumberFields } from './number_fields';
import { AccountTabs } from './tabs';

const titleFromAccount = (account: Account) => {
  const displayName = account.display_name;
  const acct =
    account.acct === account.username
      ? `${account.username}@${localDomain}`
      : account.acct;
  const prefix =
    displayName.trim().length === 0 ? account.username : displayName;

  return `${prefix} (@${acct})`;
};

export const AccountHeader: React.FC<{
  accountId: string;
  hideTabs?: boolean;
}> = ({ accountId, hideTabs }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const hidden = useAppSelector((state) => getAccountHidden(state, accountId));

  const handleOpenAvatar = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0 || e.ctrlKey || e.metaKey) {
        return;
      }

      e.preventDefault();

      if (!account) {
        return;
      }

      dispatch(
        openModal({
          modalType: 'IMAGE',
          modalProps: {
            src: account.avatar,
            alt: '',
          },
        }),
      );
    },
    [dispatch, account],
  );

  if (!account) {
    return null;
  }

  const suspendedOrHidden = hidden || account.suspended;
  const isLocal = !account.acct.includes('@');
  const username = account.acct.split('@')[0];
  const domain = isLocal ? localDomain : account.acct.split('@')[1];

  return (
    <div className='account-timeline__header'>
      {!hidden && account.memorial && <MemorialNote />}
      {!hidden && account.moved && (
        <MovedNote accountId={account.id} targetAccountId={account.moved} />
      )}

      <AnimateEmojiProvider
        className={classNames('account__header', {
          inactive: !!account.moved,
        })}
      >
        {!suspendedOrHidden && !account.moved && relationship?.requested_by && (
          <FollowRequestNoteContainer account={account} />
        )}

        <div className='account__header__image'>
          {me !== account.id && relationship && (
            <AccountInfo relationship={relationship} />
          )}

          {!suspendedOrHidden && (
            <img
              src={autoPlayGif ? account.header : account.header_static}
              alt=''
              className='parallax'
            />
          )}
        </div>

        <div className='account__header__bar'>
          <div className='account__header__tabs'>
            <a
              className='avatar'
              href={account.avatar}
              rel='noopener'
              target='_blank'
              onClick={handleOpenAvatar}
            >
              <Avatar
                account={suspendedOrHidden ? undefined : account}
                size={92}
              />
            </a>

            <AccountButtons
              accountId={accountId}
              className='account__header__buttons--desktop'
            />
          </div>

          <div className='account__header__tabs__name'>
            <h1>
              <DisplayName account={account} variant='simple' />
              <small>
                <span>
                  @{username}
                  <span className='invisible'>@{domain}</span>
                </span>
                <DomainPill
                  username={username ?? ''}
                  domain={domain ?? ''}
                  isSelf={me === account.id}
                />
                {account.locked && (
                  <Icon
                    id='lock'
                    icon={LockIcon}
                    aria-label={intl.formatMessage({
                      id: 'account.locked_info',
                      defaultMessage:
                        'This account privacy status is set to locked. The owner manually reviews who can follow them.',
                    })}
                  />
                )}
              </small>
            </h1>
          </div>

          <AccountBadges accountId={accountId} />

          {me && account.id !== me && !suspendedOrHidden && (
            <FamiliarFollowers accountId={accountId} />
          )}

          <AccountButtons
            className='account__header__buttons--mobile'
            accountId={accountId}
            noShare
          />

          {!suspendedOrHidden && (
            <div className='account__header__extra'>
              <div className='account__header__bio'>
                {me && account.id !== me && (
                  <AccountNote accountId={accountId} />
                )}

                <AccountBio
                  accountId={accountId}
                  className='account__header__content'
                />

                <div className='account__header__fields'>
                  {!isRedesignEnabled() && (
                    <dl>
                      <dt>
                        <FormattedMessage
                          id='account.joined_short'
                          defaultMessage='Joined'
                        />
                      </dt>
                      <dd>
                        <FormattedDateWrapper
                          value={account.created_at}
                          year='numeric'
                          month='short'
                          day='2-digit'
                        />
                      </dd>
                    </dl>
                  )}

                  <AccountFields
                    fields={account.fields}
                    emojis={account.emojis}
                  />
                </div>
              </div>

              <AccountNumberFields accountId={accountId} />
            </div>
          )}
        </div>
      </AnimateEmojiProvider>

      {!hideTabs && !hidden && <AccountTabs acct={account.acct} />}

      <Helmet>
        <title>{titleFromAccount(account)}</title>
        <meta
          name='robots'
          content={isLocal && !account.noindex ? 'all' : 'noindex'}
        />
        <link rel='canonical' href={account.url} />
      </Helmet>
    </div>
  );
};
