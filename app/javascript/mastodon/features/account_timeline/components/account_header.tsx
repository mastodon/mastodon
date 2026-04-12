import { useCallback } from 'react';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';

import { openModal } from '@/mastodon/actions/modal';
import { AccountBio } from '@/mastodon/components/account_bio';
import { Avatar } from '@/mastodon/components/avatar';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import FollowRequestNoteContainer from '@/mastodon/features/account/containers/follow_request_note_container';
import { useLayout } from '@/mastodon/hooks/useLayout';
import { useVisibility } from '@/mastodon/hooks/useVisibility';
import {
  autoPlayGif,
  me,
  domain as localDomain,
} from '@/mastodon/initial_state';
import type { Account } from '@/mastodon/models/account';
import { getAccountHidden } from '@/mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

import { FamiliarFollowers } from '../../../components/familiar_followers';

import { AccountName } from './account_name';
import { AccountSubscriptionForm } from './account_subscription_form';
import { AccountButtons } from './buttons';
import { AccountHeaderFields } from './fields';
import { MemorialNote } from './memorial_note';
import { MovedNote } from './moved_note';
import { AccountNote } from './note';
import { AccountNumberFields } from './number_fields';
import classes from './styles.module.scss';
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
            alt: account.avatar_description,
          },
        }),
      );
    },
    [dispatch, account],
  );

  const { layout } = useLayout();
  const { observedRef, isIntersecting } = useVisibility({
    observerOptions: {
      rootMargin: layout === 'mobile' ? '0px 0px -55px 0px' : '', // Height of bottom nav bar.
    },
  });

  if (!account) {
    return null;
  }

  const suspendedOrHidden = hidden || account.suspended;
  const isLocal = !account.acct.includes('@');
  const isMe = me && account.id === me;

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

        <div className={classNames('account__header__image', classes.header)}>
          {!suspendedOrHidden && (
            <img
              src={autoPlayGif ? account.header : account.header_static}
              alt={account.header_description}
              className='parallax'
            />
          )}
        </div>

        <div className={classNames('account__header__bar', classes.barWrapper)}>
          <div
            className={classNames(
              'account__header__tabs',
              classes.avatarWrapper,
            )}
          >
            <a
              className='avatar'
              href={account.avatar}
              rel='noopener'
              target='_blank'
              onClick={handleOpenAvatar}
            >
              <Avatar
                account={suspendedOrHidden ? undefined : account}
                alt={account.avatar_description}
                size={80}
              />
            </a>
          </div>

          <div
            className={classNames(
              'account__header__tabs__name',
              classes.displayNameWrapper,
            )}
          >
            <AccountName accountId={accountId} />
            <AccountButtons
              accountId={accountId}
              className={classes.buttonsDesktop}
              noShare={!isMe || 'share' in navigator}
              forceMenu={'share' in navigator}
            />
          </div>

          <AccountNumberFields accountId={accountId} />

          {!isMe && !suspendedOrHidden && (
            <FamiliarFollowers
              accountId={accountId}
              className={classes.familiarFollowers}
            />
          )}

          {!suspendedOrHidden && (
            <div className='account__header__extra'>
              <div className='account__header__bio'>
                {me && account.id !== me && (
                  <AccountNote accountId={accountId} />
                )}

                <AccountBio
                  showDropdown
                  accountId={accountId}
                  className={classNames(
                    'account__header__content',
                    classes.bio,
                  )}
                />

                <AccountHeaderFields accountId={accountId} />
              </div>

              {!me && account.email_subscriptions && (
                <AccountSubscriptionForm accountId={accountId} />
              )}
            </div>
          )}

          <AccountButtons
            className={classNames(
              classes.buttonsMobile,
              !isIntersecting && classes.buttonsMobileIsStuck,
            )}
            accountId={accountId}
            noShare
          />
        </div>
      </AnimateEmojiProvider>

      {!hideTabs && !hidden && <AccountTabs />}
      <div ref={observedRef} />

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
