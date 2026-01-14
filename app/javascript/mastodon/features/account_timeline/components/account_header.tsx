import { useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { NavLink } from 'react-router-dom';

import { AccountBio } from '@/mastodon/components/account_bio';
import { AccountFields } from '@/mastodon/components/account_fields';
import { DisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { Avatar } from 'mastodon/components/avatar';
import { Badge, AutomatedBadge, GroupBadge } from 'mastodon/components/badge';
import {
  FollowersCounter,
  FollowingCounter,
  StatusesCounter,
} from 'mastodon/components/counters';
import { FormattedDateWrapper } from 'mastodon/components/formatted_date';
import { Icon } from 'mastodon/components/icon';
import { ShortNumber } from 'mastodon/components/short_number';
import { AccountNote } from 'mastodon/features/account/components/account_note';
import { DomainPill } from 'mastodon/features/account/components/domain_pill';
import FollowRequestNoteContainer from 'mastodon/features/account/containers/follow_request_note_container';
import { useIdentity } from 'mastodon/identity_context';
import { autoPlayGif, me, domain as localDomain } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { AccountButtons } from './buttons';
import { FamiliarFollowers } from './familiar_followers';
import { AccountInfo } from './info';
import { MemorialNote } from './memorial_note';
import { MovedNote } from './moved_note';
import { AccountTabs } from './tabs';

const messages = defineMessages({
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  linkVerifiedOn: {
    id: 'account.link_verified_on',
    defaultMessage: 'Ownership of this link was checked on {date}',
  },
  account_locked: {
    id: 'account.locked_info',
    defaultMessage:
      'This account privacy status is set to locked. The owner manually reviews who can follow them.',
  },
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  direct: { id: 'account.direct', defaultMessage: 'Privately mention @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
  share: { id: 'account.share', defaultMessage: "Share @{name}'s profile" },
  copy: { id: 'account.copy', defaultMessage: 'Copy link to profile' },
  media: { id: 'account.media', defaultMessage: 'Media' },
  blockDomain: {
    id: 'account.block_domain',
    defaultMessage: 'Block domain {domain}',
  },
  unblockDomain: {
    id: 'account.unblock_domain',
    defaultMessage: 'Unblock domain {domain}',
  },
  hideReblogs: {
    id: 'account.hide_reblogs',
    defaultMessage: 'Hide boosts from @{name}',
  },
  showReblogs: {
    id: 'account.show_reblogs',
    defaultMessage: 'Show boosts from @{name}',
  },
  enableNotifications: {
    id: 'account.enable_notifications',
    defaultMessage: 'Notify me when @{name} posts',
  },
  disableNotifications: {
    id: 'account.disable_notifications',
    defaultMessage: 'Stop notifying me when @{name} posts',
  },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  follow_requests: {
    id: 'navigation_bar.follow_requests',
    defaultMessage: 'Follow requests',
  },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  followed_tags: {
    id: 'navigation_bar.followed_tags',
    defaultMessage: 'Followed hashtags',
  },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: {
    id: 'navigation_bar.domain_blocks',
    defaultMessage: 'Blocked domains',
  },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  endorse: { id: 'account.endorse', defaultMessage: 'Feature on profile' },
  unendorse: {
    id: 'account.unendorse',
    defaultMessage: "Don't feature on profile",
  },
  add_or_remove_from_list: {
    id: 'account.add_or_remove_from_list',
    defaultMessage: 'Add or Remove from lists',
  },
  admin_account: {
    id: 'status.admin_account',
    defaultMessage: 'Open moderation interface for @{name}',
  },
  admin_domain: {
    id: 'status.admin_domain',
    defaultMessage: 'Open moderation interface for {domain}',
  },
  languages: {
    id: 'account.languages',
    defaultMessage: 'Change subscribed languages',
  },
  openOriginalPage: {
    id: 'account.open_original_page',
    defaultMessage: 'Open original page',
  },
  removeFromFollowers: {
    id: 'account.remove_from_followers',
    defaultMessage: 'Remove {name} from followers',
  },
  confirmRemoveFromFollowersTitle: {
    id: 'confirmations.remove_from_followers.title',
    defaultMessage: 'Remove follower?',
  },
  confirmRemoveFromFollowersMessage: {
    id: 'confirmations.remove_from_followers.message',
    defaultMessage:
      '{name} will stop following you. Are you sure you want to proceed?',
  },
  confirmRemoveFromFollowersButton: {
    id: 'confirmations.remove_from_followers.confirm',
    defaultMessage: 'Remove follower',
  },
});

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
  const { signedIn } = useIdentity();
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

  const suspended = account?.suspended;

  if (!account) {
    return null;
  }

  let lockedIcon: React.ReactNode;

  if (account.locked) {
    lockedIcon = (
      <Icon
        id='lock'
        icon={LockIcon}
        aria-label={intl.formatMessage(messages.account_locked)}
      />
    );
  }

  const fields = account.fields;
  const isLocal = !account.acct.includes('@');
  const username = account.acct.split('@')[0];
  const domain = isLocal ? localDomain : account.acct.split('@')[1];
  const isIndexable = !account.noindex;

  const badges = [];

  if (account.bot) {
    badges.push(<AutomatedBadge key='bot-badge' />);
  } else if (account.group) {
    badges.push(<GroupBadge key='group-badge' />);
  }

  account.roles.forEach((role) => {
    badges.push(
      <Badge
        key={`role-badge-${role.get('id')}`}
        label={<span>{role.get('name')}</span>}
        domain={domain}
        roleId={role.get('id')}
      />,
    );
  });

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
        {!(suspended || hidden || account.moved) &&
          relationship?.requested_by && (
            <FollowRequestNoteContainer account={account} />
          )}

        <div className='account__header__image'>
          {me !== account.id && relationship && (
            <AccountInfo relationship={relationship} />
          )}

          {!(suspended || hidden) && (
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
                account={suspended || hidden ? undefined : account}
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
                {lockedIcon}
              </small>
            </h1>
          </div>

          {badges.length > 0 && (
            <div className='account__header__badges'>{badges}</div>
          )}

          {account.id !== me && signedIn && !(suspended || hidden) && (
            <FamiliarFollowers accountId={accountId} />
          )}

          <AccountButtons
            className='account__header__buttons--mobile'
            accountId={accountId}
            noShare
          />

          {!(suspended || hidden) && (
            <div className='account__header__extra'>
              <div className='account__header__bio'>
                {account.id !== me && signedIn && (
                  <AccountNote accountId={accountId} />
                )}

                <AccountBio
                  accountId={accountId}
                  className='account__header__content'
                />

                <div className='account__header__fields'>
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

                  <AccountFields fields={fields} emojis={account.emojis} />
                </div>
              </div>

              <div className='account__header__extra__links'>
                <NavLink
                  to={`/@${account.acct}`}
                  title={intl.formatNumber(account.statuses_count)}
                >
                  <ShortNumber
                    value={account.statuses_count}
                    renderer={StatusesCounter}
                  />
                </NavLink>

                <NavLink
                  exact
                  to={`/@${account.acct}/following`}
                  title={intl.formatNumber(account.following_count)}
                >
                  <ShortNumber
                    value={account.following_count}
                    renderer={FollowingCounter}
                  />
                </NavLink>

                <NavLink
                  exact
                  to={`/@${account.acct}/followers`}
                  title={intl.formatNumber(account.followers_count)}
                >
                  <ShortNumber
                    value={account.followers_count}
                    renderer={FollowersCounter}
                  />
                </NavLink>
              </div>
            </div>
          )}
        </div>
      </AnimateEmojiProvider>

      {!hideTabs && !hidden && <AccountTabs acct={account.acct} />}

      <Helmet>
        <title>{titleFromAccount(account)}</title>
        <meta
          name='robots'
          content={isLocal && isIndexable ? 'all' : 'noindex'}
        />
        <link rel='canonical' href={account.url} />
      </Helmet>
    </div>
  );
};
