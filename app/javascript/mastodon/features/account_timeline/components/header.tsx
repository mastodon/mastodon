import { useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { NavLink } from 'react-router-dom';

import { useLinks } from '@/hooks/useLinks';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import {
  followAccount,
  unblockAccount,
  unmuteAccount,
  pinAccount,
  unpinAccount,
} from 'mastodon/actions/accounts';
import { initBlockModal } from 'mastodon/actions/blocks';
import { mentionCompose, directCompose } from 'mastodon/actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from 'mastodon/actions/domain_blocks';
import { openModal } from 'mastodon/actions/modal';
import { initMuteModal } from 'mastodon/actions/mutes';
import { initReport } from 'mastodon/actions/reports';
import { Avatar } from 'mastodon/components/avatar';
import { Badge, AutomatedBadge, GroupBadge } from 'mastodon/components/badge';
import { Button } from 'mastodon/components/button';
import { CopyIconButton } from 'mastodon/components/copy_icon_button';
import {
  FollowersCounter,
  FollowingCounter,
  StatusesCounter,
} from 'mastodon/components/counters';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ShortNumber } from 'mastodon/components/short_number';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { DomainPill } from 'mastodon/features/account/components/domain_pill';
import AccountNoteContainer from 'mastodon/features/account/containers/account_note_container';
import FollowRequestNoteContainer from 'mastodon/features/account/containers/follow_request_note_container';
import { useIdentity } from 'mastodon/identity_context';
import { autoPlayGif, me, domain as localDomain } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import type { Relationship } from 'mastodon/models/relationship';
import {
  PERMISSION_MANAGE_USERS,
  PERMISSION_MANAGE_FEDERATION,
} from 'mastodon/permissions';
import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import MemorialNote from './memorial_note';
import MovedNote from './moved_note';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  followBack: { id: 'account.follow_back', defaultMessage: 'Follow back' },
  mutual: { id: 'account.mutual', defaultMessage: 'Mutual' },
  cancel_follow_request: {
    id: 'account.cancel_follow_request',
    defaultMessage: 'Withdraw follow request',
  },
  requested: {
    id: 'account.requested',
    defaultMessage: 'Awaiting approval. Click to cancel follow request',
  },
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
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
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

const messageForFollowButton = (relationship?: Relationship) => {
  if (!relationship) return messages.follow;

  if (relationship.get('following') && relationship.get('followed_by')) {
    return messages.mutual;
  } else if (relationship.get('following') || relationship.get('requested')) {
    return messages.unfollow;
  } else if (relationship.get('followed_by')) {
    return messages.followBack;
  } else {
    return messages.follow;
  }
};

const dateFormatOptions: Intl.DateTimeFormatOptions = {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
};

export const Header: React.FC<{
  accountId: string;
  hideTabs?: boolean;
}> = ({ accountId, hideTabs }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const { signedIn, permissions } = useIdentity();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const hidden = useAppSelector((state) => getAccountHidden(state, accountId));
  const handleLinkClick = useLinks();

  const handleFollow = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.following || relationship?.requested) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    } else {
      dispatch(followAccount(account.id));
    }
  }, [dispatch, account, relationship]);

  const handleBlock = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.blocking) {
      dispatch(unblockAccount(account.id));
    } else {
      dispatch(initBlockModal(account));
    }
  }, [dispatch, account, relationship]);

  const handleMention = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(mentionCompose(account));
  }, [dispatch, account]);

  const handleDirect = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(directCompose(account));
  }, [dispatch, account]);

  const handleReport = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(initReport(account));
  }, [dispatch, account]);

  const handleReblogToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.showing_reblogs) {
      dispatch(followAccount(account.id, { reblogs: false }));
    } else {
      dispatch(followAccount(account.id, { reblogs: true }));
    }
  }, [dispatch, account, relationship]);

  const handleNotifyToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.notifying) {
      dispatch(followAccount(account.id, { notify: false }));
    } else {
      dispatch(followAccount(account.id, { notify: true }));
    }
  }, [dispatch, account, relationship]);

  const handleMute = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.muting) {
      dispatch(unmuteAccount(account.id));
    } else {
      dispatch(initMuteModal(account));
    }
  }, [dispatch, account, relationship]);

  const handleBlockDomain = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(initDomainBlockModal(account));
  }, [dispatch, account]);

  const handleUnblockDomain = useCallback(() => {
    if (!account) {
      return;
    }

    const domain = account.acct.split('@')[1];

    if (!domain) {
      return;
    }

    dispatch(unblockDomain(domain));
  }, [dispatch, account]);

  const handleEndorseToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.endorsed) {
      dispatch(unpinAccount(account.id));
    } else {
      dispatch(pinAccount(account.id));
    }
  }, [dispatch, account, relationship]);

  const handleAddToList = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(
      openModal({
        modalType: 'LIST_ADDER',
        modalProps: {
          accountId: account.id,
        },
      }),
    );
  }, [dispatch, account]);

  const handleChangeLanguages = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(
      openModal({
        modalType: 'SUBSCRIBED_LANGUAGES',
        modalProps: {
          accountId: account.id,
        },
      }),
    );
  }, [dispatch, account]);

  const handleInteractionModal = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(
      openModal({
        modalType: 'INTERACTION',
        modalProps: {
          type: 'follow',
          accountId: account.id,
          url: account.uri,
        },
      }),
    );
  }, [dispatch, account]);

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

  const handleShare = useCallback(() => {
    if (!account) {
      return;
    }

    void navigator.share({
      url: account.url,
    });
  }, [account]);

  const handleEditProfile = useCallback(() => {
    window.open('/settings/profile', '_blank');
  }, []);

  const handleMouseEnter = useCallback(
    ({ currentTarget }: React.MouseEvent) => {
      if (autoPlayGif) {
        return;
      }

      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        emoji.src = emoji.getAttribute('data-original') ?? '';
      }
    },
    [],
  );

  const handleMouseLeave = useCallback(
    ({ currentTarget }: React.MouseEvent) => {
      if (autoPlayGif) {
        return;
      }

      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      for (const emoji of emojis) {
        emoji.src = emoji.getAttribute('data-static') ?? '';
      }
    },
    [],
  );

  if (!account) {
    return null;
  }

  const suspended = account.suspended;
  const isRemote = account.acct !== account.username;
  const remoteDomain = isRemote ? account.acct.split('@')[1] : null;

  let actionBtn, bellBtn, lockedIcon, shareBtn;

  const info = [];
  const menu = [];

  if (me !== account.id && relationship?.blocking) {
    info.push(
      <span key='blocked' className='relationship-tag'>
        <FormattedMessage id='account.blocked' defaultMessage='Blocked' />
      </span>,
    );
  }

  if (me !== account.id && relationship?.muting) {
    info.push(
      <span key='muted' className='relationship-tag'>
        <FormattedMessage id='account.muted' defaultMessage='Muted' />
      </span>,
    );
  } else if (me !== account.id && relationship?.domain_blocking) {
    info.push(
      <span key='domain_blocked' className='relationship-tag'>
        <FormattedMessage
          id='account.domain_blocked'
          defaultMessage='Domain blocked'
        />
      </span>,
    );
  }

  if (relationship?.requested || relationship?.following) {
    bellBtn = (
      <IconButton
        icon={relationship.notifying ? 'bell' : 'bell-o'}
        iconComponent={
          relationship.notifying ? NotificationsActiveIcon : NotificationsIcon
        }
        active={relationship.notifying}
        title={intl.formatMessage(
          relationship.notifying
            ? messages.disableNotifications
            : messages.enableNotifications,
          { name: account.username },
        )}
        onClick={handleNotifyToggle}
      />
    );
  }

  if ('share' in navigator) {
    shareBtn = (
      <IconButton
        className='optional'
        icon=''
        iconComponent={ShareIcon}
        title={intl.formatMessage(messages.share, {
          name: account.username,
        })}
        onClick={handleShare}
      />
    );
  } else {
    shareBtn = (
      <CopyIconButton
        className='optional'
        title={intl.formatMessage(messages.copy)}
        value={account.url}
      />
    );
  }

  if (me !== account.id) {
    if (signedIn && !relationship) {
      // Wait until the relationship is loaded
      actionBtn = (
        <Button disabled>
          <LoadingIndicator />
        </Button>
      );
    } else if (!relationship?.blocking) {
      actionBtn = (
        <Button
          disabled={relationship?.blocked_by}
          className={classNames({
            'button--destructive':
              relationship?.following || relationship?.requested,
          })}
          text={intl.formatMessage(messageForFollowButton(relationship))}
          onClick={signedIn ? handleFollow : handleInteractionModal}
        />
      );
    } else {
      actionBtn = (
        <Button
          text={intl.formatMessage(messages.unblock, {
            name: account.username,
          })}
          onClick={handleBlock}
        />
      );
    }
  } else {
    actionBtn = (
      <Button
        text={intl.formatMessage(messages.edit_profile)}
        onClick={handleEditProfile}
      />
    );
  }

  if (account.moved && !relationship?.following) {
    actionBtn = '';
  }

  if (account.locked) {
    lockedIcon = (
      <Icon
        id='lock'
        icon={LockIcon}
        title={intl.formatMessage(messages.account_locked)}
      />
    );
  }

  if (signedIn && account.id !== me && !account.suspended) {
    menu.push({
      text: intl.formatMessage(messages.mention, {
        name: account.username,
      }),
      action: handleMention,
    });
    menu.push({
      text: intl.formatMessage(messages.direct, {
        name: account.username,
      }),
      action: handleDirect,
    });
    menu.push(null);
  }

  if (isRemote) {
    menu.push({
      text: intl.formatMessage(messages.openOriginalPage),
      href: account.url,
    });
    menu.push(null);
  }

  if (account.id === me) {
    menu.push({
      text: intl.formatMessage(messages.edit_profile),
      href: '/settings/profile',
    });
    menu.push({
      text: intl.formatMessage(messages.preferences),
      href: '/settings/preferences',
    });
    menu.push({ text: intl.formatMessage(messages.pins), to: '/pinned' });
    menu.push(null);
    menu.push({
      text: intl.formatMessage(messages.follow_requests),
      to: '/follow_requests',
    });
    menu.push({
      text: intl.formatMessage(messages.favourites),
      to: '/favourites',
    });
    menu.push({ text: intl.formatMessage(messages.lists), to: '/lists' });
    menu.push({
      text: intl.formatMessage(messages.followed_tags),
      to: '/followed_tags',
    });
    menu.push(null);
    menu.push({ text: intl.formatMessage(messages.mutes), to: '/mutes' });
    menu.push({ text: intl.formatMessage(messages.blocks), to: '/blocks' });
    menu.push({
      text: intl.formatMessage(messages.domain_blocks),
      to: '/domain_blocks',
    });
  } else if (signedIn) {
    if (relationship?.following) {
      if (!relationship.muting) {
        if (relationship.showing_reblogs) {
          menu.push({
            text: intl.formatMessage(messages.hideReblogs, {
              name: account.username,
            }),
            action: handleReblogToggle,
          });
        } else {
          menu.push({
            text: intl.formatMessage(messages.showReblogs, {
              name: account.username,
            }),
            action: handleReblogToggle,
          });
        }

        menu.push({
          text: intl.formatMessage(messages.languages),
          action: handleChangeLanguages,
        });
        menu.push(null);
      }

      menu.push({
        text: intl.formatMessage(
          account.getIn(['relationship', 'endorsed'])
            ? messages.unendorse
            : messages.endorse,
        ),
        action: handleEndorseToggle,
      });
      menu.push({
        text: intl.formatMessage(messages.add_or_remove_from_list),
        action: handleAddToList,
      });
      menu.push(null);
    }

    if (relationship?.muting) {
      menu.push({
        text: intl.formatMessage(messages.unmute, {
          name: account.username,
        }),
        action: handleMute,
      });
    } else {
      menu.push({
        text: intl.formatMessage(messages.mute, {
          name: account.username,
        }),
        action: handleMute,
        dangerous: true,
      });
    }

    if (relationship?.blocking) {
      menu.push({
        text: intl.formatMessage(messages.unblock, {
          name: account.username,
        }),
        action: handleBlock,
      });
    } else {
      menu.push({
        text: intl.formatMessage(messages.block, {
          name: account.username,
        }),
        action: handleBlock,
        dangerous: true,
      });
    }

    if (!account.suspended) {
      menu.push({
        text: intl.formatMessage(messages.report, {
          name: account.username,
        }),
        action: handleReport,
        dangerous: true,
      });
    }
  }

  if (signedIn && isRemote) {
    menu.push(null);

    if (relationship?.domain_blocking) {
      menu.push({
        text: intl.formatMessage(messages.unblockDomain, {
          domain: remoteDomain,
        }),
        action: handleUnblockDomain,
      });
    } else {
      menu.push({
        text: intl.formatMessage(messages.blockDomain, {
          domain: remoteDomain,
        }),
        action: handleBlockDomain,
        dangerous: true,
      });
    }
  }

  if (
    (account.id !== me &&
      (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) ||
    (isRemote &&
      (permissions & PERMISSION_MANAGE_FEDERATION) ===
        PERMISSION_MANAGE_FEDERATION)
  ) {
    menu.push(null);
    if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
      menu.push({
        text: intl.formatMessage(messages.admin_account, {
          name: account.username,
        }),
        href: `/admin/accounts/${account.id}`,
      });
    }
    if (
      isRemote &&
      (permissions & PERMISSION_MANAGE_FEDERATION) ===
        PERMISSION_MANAGE_FEDERATION
    ) {
      menu.push({
        text: intl.formatMessage(messages.admin_domain, {
          domain: remoteDomain,
        }),
        href: `/admin/instances/${remoteDomain}`,
      });
    }
  }

  const content = { __html: account.note_emojified };
  const displayNameHtml = { __html: account.display_name_html };
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

  account.get('roles', []).forEach((role) => {
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
        <MovedNote from={account} to={account.moved} />
      )}

      <div
        className={classNames('account__header', {
          inactive: !!account.moved,
        })}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
      >
        {!(suspended || hidden || account.moved) &&
          relationship?.requested_by && (
            <FollowRequestNoteContainer account={account} />
          )}

        <div className='account__header__image'>
          <div className='account__header__info'>{info}</div>

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
                size={90}
              />
            </a>

            <div className='account__header__tabs__buttons'>
              {!hidden && bellBtn}
              {!hidden && shareBtn}
              <DropdownMenuContainer
                disabled={menu.length === 0}
                items={menu}
                icon='ellipsis-v'
                iconComponent={MoreHorizIcon}
                size={24}
                direction='right'
              />
              {!hidden && actionBtn}
            </div>
          </div>

          <div className='account__header__tabs__name'>
            <h1>
              <span dangerouslySetInnerHTML={displayNameHtml} />
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

          {!(suspended || hidden) && (
            <div className='account__header__extra'>
              <div
                className='account__header__bio'
                onClickCapture={handleLinkClick}
              >
                {account.id !== me && signedIn && (
                  <AccountNoteContainer account={account} />
                )}

                {account.note.length > 0 && account.note !== '<p></p>' && (
                  <div
                    className='account__header__content translate'
                    dangerouslySetInnerHTML={content}
                  />
                )}

                <div className='account__header__fields'>
                  <dl>
                    <dt>
                      <FormattedMessage
                        id='account.joined_short'
                        defaultMessage='Joined'
                      />
                    </dt>
                    <dd>
                      {intl.formatDate(account.created_at, {
                        year: 'numeric',
                        month: 'short',
                        day: '2-digit',
                      })}
                    </dd>
                  </dl>

                  {fields.map((pair, i) => (
                    <dl
                      key={i}
                      className={classNames({
                        verified: pair.verified_at,
                      })}
                    >
                      <dt
                        dangerouslySetInnerHTML={{
                          __html: pair.name_emojified,
                        }}
                        title={pair.name}
                        className='translate'
                      />

                      <dd className='translate' title={pair.value_plain ?? ''}>
                        {pair.verified_at && (
                          <span
                            title={intl.formatMessage(messages.linkVerifiedOn, {
                              date: intl.formatDate(
                                pair.verified_at,
                                dateFormatOptions,
                              ),
                            })}
                          >
                            <Icon
                              id='check'
                              icon={CheckIcon}
                              className='verified__mark'
                            />
                          </span>
                        )}{' '}
                        <span
                          dangerouslySetInnerHTML={{
                            __html: pair.value_emojified,
                          }}
                        />
                      </dd>
                    </dl>
                  ))}
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
      </div>

      {!(hideTabs || hidden) && (
        <div className='account__section-headline'>
          <NavLink exact to={`/@${account.acct}`}>
            <FormattedMessage id='account.posts' defaultMessage='Posts' />
          </NavLink>
          <NavLink exact to={`/@${account.acct}/with_replies`}>
            <FormattedMessage
              id='account.posts_with_replies'
              defaultMessage='Posts and replies'
            />
          </NavLink>
          <NavLink exact to={`/@${account.acct}/media`}>
            <FormattedMessage id='account.media' defaultMessage='Media' />
          </NavLink>
        </div>
      )}

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
