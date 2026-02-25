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
import { showAlert } from '@/mastodon/actions/alerts';
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
import type { Account } from '@/mastodon/models/account';
import type { MenuItem } from '@/mastodon/models/dropdown_menu';
import type { Relationship } from '@/mastodon/models/relationship';
import {
  PERMISSION_MANAGE_FEDERATION,
  PERMISSION_MANAGE_USERS,
} from '@/mastodon/permissions';
import type { AppDispatch } from '@/mastodon/store';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import BlockIcon from '@/material-icons/400-24px/block.svg?react';
import LinkIcon from '@/material-icons/400-24px/link_2.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import PersonRemoveIcon from '@/material-icons/400-24px/person_remove.svg?react';
import ReportIcon from '@/material-icons/400-24px/report.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountMenu: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const { signedIn, permissions } = useIdentity();

  const account = useAccount(accountId);
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const currentAccountId = useAppSelector(
    (state) => state.meta.get('me') as string,
  );
  const isMe = currentAccountId === accountId;

  const dispatch = useAppDispatch();
  const menuItems = useMemo(() => {
    if (!account) {
      return [];
    }

    if (isRedesignEnabled()) {
      return redesignMenuItems({
        account,
        signedIn: !isMe && signedIn,
        permissions,
        intl,
        relationship,
        dispatch,
      });
    }
    return currentMenuItems({
      account,
      signedIn,
      permissions,
      intl,
      relationship,
      dispatch,
    });
  }, [account, signedIn, isMe, permissions, intl, relationship, dispatch]);
  return (
    <Dropdown
      disabled={menuItems.length === 0}
      items={menuItems}
      icon='ellipsis-v'
      iconComponent={MoreHorizIcon}
      className={classes.buttonMenu}
    />
  );
};

interface MenuItemsParams {
  account: Account;
  signedIn: boolean;
  permissions: number;
  intl: ReturnType<typeof useIntl>;
  relationship?: Relationship;
  dispatch: AppDispatch;
}

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

function currentMenuItems({
  account,
  signedIn,
  permissions,
  intl,
  relationship,
  dispatch,
}: MenuItemsParams): MenuItem[] {
  const items: MenuItem[] = [];
  const isRemote = account.acct !== account.username;

  if (signedIn && !account.suspended) {
    items.push(
      {
        text: intl.formatMessage(messages.mention, {
          name: account.username,
        }),
        action: () => {
          dispatch(mentionCompose(account));
        },
      },
      {
        text: intl.formatMessage(messages.direct, {
          name: account.username,
        }),
        action: () => {
          dispatch(directCompose(account));
        },
      },
      null,
    );
  }

  if (isRemote) {
    items.push(
      {
        text: intl.formatMessage(messages.openOriginalPage),
        href: account.url,
      },
      null,
    );
  }

  if (!signedIn) {
    return items;
  }

  if (relationship?.following) {
    // Timeline options
    if (!relationship.muting) {
      if (relationship.showing_reblogs) {
        items.push({
          text: intl.formatMessage(messages.hideReblogs, {
            name: account.username,
          }),
          action: () => {
            dispatch(followAccount(account.id, { reblogs: false }));
          },
        });
      } else {
        items.push({
          text: intl.formatMessage(messages.showReblogs, {
            name: account.username,
          }),
          action: () => {
            dispatch(followAccount(account.id, { reblogs: true }));
          },
        });
      }

      items.push(
        {
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
        },
        null,
      );
    }

    items.push(
      {
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
      },
      {
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
      },
      null,
    );
  }

  if (relationship?.followed_by) {
    const handleRemoveFromFollowers = () => {
      dispatch(
        openModal({
          modalType: 'CONFIRM',
          modalProps: {
            title: intl.formatMessage(messages.confirmRemoveFromFollowersTitle),
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

    items.push({
      text: intl.formatMessage(messages.removeFromFollowers, {
        name: account.username,
      }),
      action: handleRemoveFromFollowers,
      dangerous: true,
    });
  }

  if (relationship?.muting) {
    items.push({
      text: intl.formatMessage(messages.unmute, {
        name: account.username,
      }),
      action: () => {
        dispatch(unmuteAccount(account.id));
      },
    });
  } else {
    items.push({
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
    items.push({
      text: intl.formatMessage(messages.unblock, {
        name: account.username,
      }),
      action: () => {
        dispatch(unblockAccount(account.id));
      },
    });
  } else {
    items.push({
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
    items.push({
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
    items.push(null);

    if (relationship?.domain_blocking) {
      items.push({
        text: intl.formatMessage(messages.unblockDomain, {
          domain: remoteDomain,
        }),
        action: () => {
          dispatch(unblockDomain(remoteDomain));
        },
      });
    } else {
      items.push({
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
    items.push(null);
    if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
      items.push({
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
      items.push({
        text: intl.formatMessage(messages.admin_domain, {
          domain: remoteDomain,
        }),
        href: `/admin/instances/${remoteDomain}`,
      });
    }
  }

  return items;
}

const redesignMessages = defineMessages({
  share: { id: 'account.menu.share', defaultMessage: 'Share…' },
  copy: { id: 'account.menu.copy', defaultMessage: 'Copy link' },
  copied: {
    id: 'account.menu.copied',
    defaultMessage: 'Copied account link to clipboard',
  },
  mention: { id: 'account.menu.mention', defaultMessage: 'Mention' },
  noteDescription: {
    id: 'account.menu.note.description',
    defaultMessage: 'Visible only to you',
  },
  direct: {
    id: 'account.menu.direct',
    defaultMessage: 'Privately mention',
  },
  mute: { id: 'account.menu.mute', defaultMessage: 'Mute account' },
  unmute: {
    id: 'account.menu.unmute',
    defaultMessage: 'Unmute account',
  },
  block: { id: 'account.menu.block', defaultMessage: 'Block account' },
  unblock: {
    id: 'account.menu.unblock',
    defaultMessage: 'Unblock account',
  },
  domainBlock: {
    id: 'account.menu.block_domain',
    defaultMessage: 'Block {domain}',
  },
  domainUnblock: {
    id: 'account.menu.unblock_domain',
    defaultMessage: 'Unblock {domain}',
  },
  report: { id: 'account.menu.report', defaultMessage: 'Report account' },
  hideReblogs: {
    id: 'account.menu.hide_reblogs',
    defaultMessage: 'Hide boosts in timeline',
  },
  showReblogs: {
    id: 'account.menu.show_reblogs',
    defaultMessage: 'Show boosts in timeline',
  },
  addToList: {
    id: 'account.menu.add_to_list',
    defaultMessage: 'Add to list…',
  },
  openOriginalPage: {
    id: 'account.menu.open_original_page',
    defaultMessage: 'View on {domain}',
  },
  removeFollower: {
    id: 'account.menu.remove_follower',
    defaultMessage: 'Remove follower',
  },
});

function redesignMenuItems({
  account,
  signedIn,
  permissions,
  intl,
  relationship,
  dispatch,
}: MenuItemsParams): MenuItem[] {
  const items: MenuItem[] = [];
  const isRemote = account.acct !== account.username;
  const remoteDomain = isRemote ? account.acct.split('@')[1] : null;

  // Share and copy link options
  if (account.url) {
    if ('share' in navigator) {
      items.push({
        text: intl.formatMessage(redesignMessages.share),
        action: () => {
          void navigator.share({
            url: account.url,
          });
        },
        icon: ShareIcon,
      });
    }
    items.push({
      text: intl.formatMessage(redesignMessages.copy),
      action: () => {
        void navigator.clipboard.writeText(account.url);
        dispatch(showAlert({ message: redesignMessages.copied }));
      },
      icon: LinkIcon,
    });
  }

  // Open on remote page.
  if (isRemote) {
    items.push({
      text: intl.formatMessage(redesignMessages.openOriginalPage, {
        domain: remoteDomain,
      }),
      href: account.url,
    });
  }

  // Mention and direct message options
  if (signedIn && !account.suspended) {
    items.push(
      null,
      {
        text: intl.formatMessage(redesignMessages.mention),
        action: () => {
          dispatch(mentionCompose(account));
        },
      },

      {
        text: intl.formatMessage(redesignMessages.direct),
        action: () => {
          dispatch(directCompose(account));
        },
      },
      null,
    );
  }

  if (!signedIn) {
    return items;
  }

  // List and featuring options
  if (relationship?.following) {
    items.push(
      {
        text: intl.formatMessage(redesignMessages.addToList),
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
      },
      {
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
      },
    );
  }

  items.push(
    {
      text: intl.formatMessage(
        relationship?.note ? messages.editNote : messages.addNote,
      ),
      description: intl.formatMessage(redesignMessages.noteDescription),
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
    },
    null,
  );

  // Timeline options
  if (relationship && !relationship.muting) {
    items.push(
      {
        text: intl.formatMessage(
          relationship.showing_reblogs
            ? redesignMessages.hideReblogs
            : redesignMessages.showReblogs,
        ),
        action: () => {
          dispatch(
            followAccount(account.id, {
              reblogs: !relationship.showing_reblogs,
            }),
          );
        },
      },
      {
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
      },
    );
  }

  items.push(
    {
      text: intl.formatMessage(
        relationship?.muting ? redesignMessages.unmute : redesignMessages.mute,
      ),
      action: () => {
        if (relationship?.muting) {
          dispatch(unmuteAccount(account.id));
        } else {
          dispatch(initMuteModal(account));
        }
      },
    },
    null,
  );

  if (relationship?.followed_by) {
    items.push({
      text: intl.formatMessage(redesignMessages.removeFollower),
      action: () => {
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
      },
      dangerous: true,
      icon: PersonRemoveIcon,
    });
  }

  items.push({
    text: intl.formatMessage(
      relationship?.blocking
        ? redesignMessages.unblock
        : redesignMessages.block,
    ),
    action: () => {
      if (relationship?.blocking) {
        dispatch(unblockAccount(account.id));
      } else {
        dispatch(blockAccount(account.id));
      }
    },
    dangerous: true,
    icon: BlockIcon,
  });

  if (!account.suspended) {
    items.push({
      text: intl.formatMessage(redesignMessages.report),
      action: () => {
        dispatch(initReport(account));
      },
      dangerous: true,
      icon: ReportIcon,
    });
  }

  if (remoteDomain) {
    items.push(null, {
      text: intl.formatMessage(
        relationship?.domain_blocking
          ? redesignMessages.domainUnblock
          : redesignMessages.domainBlock,
        {
          domain: remoteDomain,
        },
      ),
      action: () => {
        if (relationship?.domain_blocking) {
          dispatch(unblockDomain(remoteDomain));
        } else {
          dispatch(initDomainBlockModal(account));
        }
      },
      dangerous: true,
      icon: BlockIcon,
      iconId: 'domain-block',
    });
  }

  if (
    (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS ||
    (isRemote &&
      (permissions & PERMISSION_MANAGE_FEDERATION) ===
        PERMISSION_MANAGE_FEDERATION)
  ) {
    items.push(null);
    if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
      items.push({
        text: intl.formatMessage(messages.admin_account, {
          name: account.username,
        }),
        href: `/admin/accounts/${account.id}`,
      });
    }
    if (
      remoteDomain &&
      (permissions & PERMISSION_MANAGE_FEDERATION) ===
        PERMISSION_MANAGE_FEDERATION
    ) {
      items.push({
        text: intl.formatMessage(messages.admin_domain, {
          domain: remoteDomain,
        }),
        href: `/admin/instances/${remoteDomain}`,
      });
    }
  }

  return items;
}
