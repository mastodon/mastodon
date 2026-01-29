import { useMemo } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import {
  blockAccount,
  followAccount,
  pinAccount,
  unblockAccount,
  unmuteAccount,
  unpinAccount,
} from '@/mastodon/actions/accounts';
import { removeAccountFromFollowers } from '@/mastodon/actions/accounts_typed';
import { directCompose, mentionCompose } from '@/mastodon/actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from '@/mastodon/actions/domain_blocks';
import { openModal } from '@/mastodon/actions/modal';
import { initMuteModal } from '@/mastodon/actions/mutes';
import { initReport } from '@/mastodon/actions/reports';
import { Dropdown } from '@/mastodon/components/dropdown_menu';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import type { MenuItem } from '@/mastodon/models/dropdown_menu';
import {
  PERMISSION_MANAGE_FEDERATION,
  PERMISSION_MANAGE_USERS,
} from '@/mastodon/permissions';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { isRedesignEnabled } from '../common';

const messages = defineMessages({
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  direct: { id: 'account.direct', defaultMessage: 'Privately mention @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
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
  addNote: {
    id: 'account.add_note',
    defaultMessage: 'Add a personal note',
  },
  editNote: {
    id: 'account.edit_note',
    defaultMessage: 'Edit personal note',
  },
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

export const AccountMenu: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const { signedIn, permissions } = useIdentity();

  const account = useAccount(accountId);
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );

  const dispatch = useAppDispatch();
  const menuItems = useMemo(() => {
    const arr: MenuItem[] = [];

    if (!account) {
      return arr;
    }

    const isRemote = account.acct !== account.username;

    if (signedIn && !account.suspended) {
      arr.push({
        text: intl.formatMessage(messages.mention, {
          name: account.username,
        }),
        action: () => {
          dispatch(mentionCompose(account));
        },
      });
      arr.push({
        text: intl.formatMessage(messages.direct, {
          name: account.username,
        }),
        action: () => {
          dispatch(directCompose(account));
        },
      });
      arr.push(null);
    }

    if (isRemote) {
      arr.push({
        text: intl.formatMessage(messages.openOriginalPage),
        href: account.url,
      });
      arr.push(null);
    }

    if (!signedIn) {
      return arr;
    }

    if (relationship?.following) {
      if (!relationship.muting) {
        if (relationship.showing_reblogs) {
          arr.push({
            text: intl.formatMessage(messages.hideReblogs, {
              name: account.username,
            }),
            action: () => {
              dispatch(followAccount(account.id, { reblogs: false }));
            },
          });
        } else {
          arr.push({
            text: intl.formatMessage(messages.showReblogs, {
              name: account.username,
            }),
            action: () => {
              dispatch(followAccount(account.id, { reblogs: true }));
            },
          });
        }

        arr.push({
          text: intl.formatMessage(messages.languages),
          action: () => {
            dispatch(
              openModal({
                modalType: 'SUBSCRIBED_LANGUAGES',
                modalProps: {
                  accountId: account.id,
                },
              }),
            );
          },
        });
        arr.push(null);
      }
    }

    if (isRedesignEnabled()) {
      arr.push({
        text: intl.formatMessage(
          relationship?.note ? messages.editNote : messages.addNote,
        ),
        action: () => {
          dispatch(
            openModal({
              modalType: 'ACCOUNT_NOTE',
              modalProps: {
                accountId: account.id,
              },
            }),
          );
        },
      });
      if (!relationship?.following) {
        arr.push(null);
      }
    }

    if (relationship?.following) {
      arr.push({
        text: intl.formatMessage(
          relationship.endorsed ? messages.unendorse : messages.endorse,
        ),
        action: () => {
          if (relationship.endorsed) {
            dispatch(unpinAccount(account.id));
          } else {
            dispatch(pinAccount(account.id));
          }
        },
      });
      arr.push({
        text: intl.formatMessage(messages.add_or_remove_from_list),
        action: () => {
          dispatch(
            openModal({
              modalType: 'LIST_ADDER',
              modalProps: {
                accountId: account.id,
              },
            }),
          );
        },
      });
      arr.push(null);
    }

    if (relationship?.followed_by) {
      const handleRemoveFromFollowers = () => {
        dispatch(
          openModal({
            modalType: 'CONFIRM',
            modalProps: {
              title: intl.formatMessage(
                messages.confirmRemoveFromFollowersTitle,
              ),
              message: intl.formatMessage(
                messages.confirmRemoveFromFollowersMessage,
                { name: <strong>{account.acct}</strong> },
              ),
              confirm: intl.formatMessage(
                messages.confirmRemoveFromFollowersButton,
              ),
              onConfirm: () => {
                void dispatch(
                  removeAccountFromFollowers({ accountId: account.id }),
                );
              },
            },
          }),
        );
      };

      arr.push({
        text: intl.formatMessage(messages.removeFromFollowers, {
          name: account.username,
        }),
        action: handleRemoveFromFollowers,
        dangerous: true,
      });
    }

    if (relationship?.muting) {
      arr.push({
        text: intl.formatMessage(messages.unmute, {
          name: account.username,
        }),
        action: () => {
          dispatch(unmuteAccount(account.id));
        },
      });
    } else {
      arr.push({
        text: intl.formatMessage(messages.mute, {
          name: account.username,
        }),
        action: () => {
          dispatch(initMuteModal(account));
        },
        dangerous: true,
      });
    }

    if (relationship?.blocking) {
      arr.push({
        text: intl.formatMessage(messages.unblock, {
          name: account.username,
        }),
        action: () => {
          dispatch(unblockAccount(account.id));
        },
      });
    } else {
      arr.push({
        text: intl.formatMessage(messages.block, {
          name: account.username,
        }),
        action: () => {
          dispatch(blockAccount(account.id));
        },
        dangerous: true,
      });
    }

    if (!account.suspended) {
      arr.push({
        text: intl.formatMessage(messages.report, {
          name: account.username,
        }),
        action: () => {
          dispatch(initReport(account));
        },
        dangerous: true,
      });
    }

    const remoteDomain = isRemote ? account.acct.split('@')[1] : null;
    if (remoteDomain) {
      arr.push(null);

      if (relationship?.domain_blocking) {
        arr.push({
          text: intl.formatMessage(messages.unblockDomain, {
            domain: remoteDomain,
          }),
          action: () => {
            dispatch(unblockDomain(remoteDomain));
          },
        });
      } else {
        arr.push({
          text: intl.formatMessage(messages.blockDomain, {
            domain: remoteDomain,
          }),
          action: () => {
            dispatch(initDomainBlockModal(account));
          },
          dangerous: true,
        });
      }
    }

    if (
      (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS ||
      (isRemote &&
        (permissions & PERMISSION_MANAGE_FEDERATION) ===
          PERMISSION_MANAGE_FEDERATION)
    ) {
      arr.push(null);
      if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
        arr.push({
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
        arr.push({
          text: intl.formatMessage(messages.admin_domain, {
            domain: remoteDomain,
          }),
          href: `/admin/instances/${remoteDomain}`,
        });
      }
    }

    return arr;
  }, [account, signedIn, permissions, intl, relationship, dispatch]);
  return (
    <Dropdown
      disabled={menuItems.length === 0}
      items={menuItems}
      icon='ellipsis-v'
      iconComponent={MoreHorizIcon}
    />
  );
};
