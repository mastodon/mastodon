import { useMemo } from 'react';
import type { FC } from 'react';

import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { IconButton } from '@/mastodon/components/icon_button';
import { ModalShell, ModalShellBody } from '@/mastodon/components/modal_shell';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useAppSelector } from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import classes from './styles.module.css';

const closeMessage = defineMessage({
  id: 'lightbox.close',
  defaultMessage: 'Close',
});

export const AccountJoinModal: FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const currentId = useCurrentAccountId();

  const createdAtStr = account?.created_at;
  const anniversary = useMemo(() => {
    if (!createdAtStr) {
      return null;
    }
    const now = new Date();
    const createdAt = new Date(createdAtStr);
    if (
      now.getMonth() === createdAt.getMonth() &&
      now.getDate() === createdAt.getDate()
    ) {
      return now.getFullYear() - createdAt.getFullYear();
    }
    return null;
  }, [createdAtStr]);

  return (
    <ModalShell>
      <ModalShellBody className={classes.joinWrapper}>
        <AccountJoinMessage
          name={<DisplayNameSimple account={account} />}
          isMe={accountId === currentId}
          anniversary={anniversary}
        />
        <h1>
          <FormattedDateWrapper
            value={account?.created_at}
            month='short'
            day='numeric'
            year='numeric'
          />
        </h1>
        <IconButton
          iconComponent={CloseIcon}
          icon='times'
          onClick={onClose}
          title={intl.formatMessage(closeMessage)}
          className={classes.joinClose}
        />
      </ModalShellBody>
    </ModalShell>
  );
};

const AccountJoinMessage: FC<{
  name: React.JSX.Element;
  isMe: boolean;
  anniversary: number | null;
}> = ({ name, isMe, anniversary }) => {
  const serverName = useAppSelector(
    (state) => state.server.getIn(['server', 'title']) as string | undefined,
  );

  if (anniversary === 0) {
    if (isMe) {
      return (
        <FormattedMessage
          id='account.join_modal.me_today'
          defaultMessage='It’s your first day on {server}!'
          tagName='p'
          values={{
            server: serverName,
          }}
        />
      );
    }
    return (
      <FormattedMessage
        id='account.join_modal.other_today'
        defaultMessage='It’s {name} first day on {server}!'
        tagName='p'
        values={{
          name,
          server: serverName,
        }}
      />
    );
  }

  if (isMe) {
    return (
      <FormattedMessage
        id='account.join_modal.me'
        defaultMessage='You joined {server} on'
        tagName='p'
        values={{
          server: serverName,
        }}
      />
    );
  }

  return (
    <FormattedMessage
      id='account.join_modal.other'
      defaultMessage='{name} joined {server} on'
      tagName='p'
      values={{
        name,
        server: serverName,
      }}
    />
  );
};
