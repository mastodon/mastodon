import { useCallback } from 'react';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';

import { openModal } from '@/mastodon/actions/modal';
import { AccountBio } from '@/mastodon/components/account_bio';
import { Avatar } from '@/mastodon/components/avatar';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import { AccountNote } from '@/mastodon/features/account/components/account_note';
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

import { isRedesignEnabled } from '../common';

import { AccountName } from './account_name';
import { AccountBadges } from './badges';
import { AccountButtons } from './buttons';
import { FamiliarFollowers } from './familiar_followers';
import { AccountHeaderFields } from './fields';
import { AccountInfo } from './info';
import { MemorialNote } from './memorial_note';
import { MovedNote } from './moved_note';
import { AccountNote as AccountNoteRedesign } from './note';
import { AccountNumberFields } from './number_fields';
import redesignClasses from './redesign.module.scss';
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
  const isRedesign = isRedesignEnabled();

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
            alt: '',
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

        <div
          className={classNames(
            'account__header__image',
            isRedesign && redesignClasses.header,
          )}
        >
          {me !== account.id && relationship && !isRedesign && (
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

        <div
          className={classNames(
            'account__header__bar',
            isRedesign && redesignClasses.barWrapper,
          )}
        >
          <div
            className={classNames(
              'account__header__tabs',
              isRedesign && redesignClasses.avatarWrapper,
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
                size={isRedesign ? 80 : 92}
              />
            </a>

            {!isRedesign && (
              <AccountButtons
                accountId={accountId}
                className='account__header__buttons--desktop'
              />
            )}
          </div>

          <div
            className={classNames(
              'account__header__tabs__name',
              isRedesign && redesignClasses.nameWrapper,
            )}
          >
            <AccountName accountId={accountId} />
            {isRedesign && (
              <AccountButtons
                accountId={accountId}
                className={redesignClasses.buttonsDesktop}
                noShare={!isMe || 'share' in navigator}
                forceMenu={'share' in navigator}
              />
            )}
          </div>

          <AccountBadges accountId={accountId} />

          {!isMe && !suspendedOrHidden && (
            <FamiliarFollowers accountId={accountId} />
          )}

          {!isRedesign && (
            <AccountButtons
              className='account__header__buttons--mobile'
              accountId={accountId}
              noShare
            />
          )}

          {!suspendedOrHidden && (
            <div className='account__header__extra'>
              <div className='account__header__bio'>
                {me &&
                  account.id !== me &&
                  (isRedesign ? (
                    <AccountNoteRedesign accountId={accountId} />
                  ) : (
                    <AccountNote accountId={accountId} />
                  ))}

                {(!isRedesign || layout === 'single-column') && (
                  <>
                    <AccountBio
                      accountId={accountId}
                      className={classNames(
                        'account__header__content',
                        isRedesign && redesignClasses.bio,
                      )}
                    />
                    <AccountHeaderFields accountId={accountId} />
                  </>
                )}
              </div>

              <AccountNumberFields accountId={accountId} />
            </div>
          )}

          {isRedesign && (
            <AccountButtons
              className={classNames(
                redesignClasses.buttonsMobile,
                !isIntersecting && redesignClasses.buttonsMobileIsStuck,
              )}
              accountId={accountId}
              noShare
            />
          )}
        </div>
      </AnimateEmojiProvider>

      {!hideTabs && !hidden && <AccountTabs acct={account.acct} />}
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
