import { useCallback } from 'react';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';

import { openModal } from '@/flavours/glitch/actions/modal';
import { AccountBio } from '@/flavours/glitch/components/account_bio';
import { Avatar } from '@/flavours/glitch/components/avatar';
import { AnimateEmojiProvider } from '@/flavours/glitch/components/emoji/context';
import { AccountNote } from '@/flavours/glitch/features/account/components/account_note';
import FollowRequestNoteContainer from '@/flavours/glitch/features/account/containers/follow_request_note_container';
import { useLayout } from '@/flavours/glitch/hooks/useLayout';
import { useVisibility } from '@/flavours/glitch/hooks/useVisibility';
import {
  autoPlayGif,
  me,
  domain as localDomain,
} from '@/flavours/glitch/initial_state';
import type { Account } from '@/flavours/glitch/models/account';
import { getAccountHidden } from '@/flavours/glitch/selectors/accounts';
import { useAppSelector, useAppDispatch } from '@/flavours/glitch/store';

import { ActionBar } from '../../account/components/action_bar';
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

                <AccountBio
                  accountId={accountId}
                  className={classNames(
                    'account__header__content',
                    isRedesign && redesignClasses.bio,
                  )}
                />
                <AccountHeaderFields accountId={accountId} />
              </div>
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

      <ActionBar account={account} />

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
