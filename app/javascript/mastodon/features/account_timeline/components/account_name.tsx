import { useCallback, useId, useRef, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/esm/Overlay';

import { DisplayName } from '@/mastodon/components/display_name';
import { Icon } from '@/mastodon/components/icon';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAppSelector } from '@/mastodon/store';
import AtIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import HelpIcon from '@/material-icons/400-24px/help.svg?react';
import DomainIcon from '@/material-icons/400-24px/language.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';

import { DomainPill } from '../../account/components/domain_pill';
import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

const messages = defineMessages({
  lockedInfo: {
    id: 'account.locked_info',
    defaultMessage:
      'This account privacy status is set to locked. The owner manually reviews who can follow them.',
  },
  nameInfo: {
    id: 'account.name_info',
    defaultMessage: 'What does this mean?',
  },
});

export const AccountName: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const me = useAppSelector((state) => state.meta.get('me') as string);
  const localDomain = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );

  if (!account) {
    return null;
  }

  const [username = '', domain = localDomain] = account.acct.split('@');

  if (!isRedesignEnabled()) {
    return (
      <h1>
        <DisplayName account={account} variant='simple' />
        <small>
          <span>
            @{username}
            <span className='invisible'>@{domain}</span>
          </span>
          <DomainPill
            username={username}
            domain={domain}
            isSelf={me === account.id}
          />
          {account.locked && (
            <Icon
              id='lock'
              icon={LockIcon}
              aria-label={intl.formatMessage(messages.lockedInfo)}
            />
          )}
        </small>
      </h1>
    );
  }

  return (
    <div className={classes.name}>
      <h1>
        <DisplayName account={account} variant='simple' />
      </h1>
      <p className={classes.username}>
        @{username}@{domain}
        <AccountNameHelp
          username={username}
          domain={domain}
          isSelf={account.id === me}
        />
      </p>
    </div>
  );
};

const AccountNameHelp: FC<{
  username: string;
  domain: string;
  isSelf: boolean;
}> = ({ username, domain, isSelf }) => {
  const accessibilityId = useId();
  const intl = useIntl();
  const [open, setOpen] = useState(false);
  const triggerRef = useRef<HTMLButtonElement>(null);

  const handleClick = useCallback(() => {
    setOpen((prev) => !prev);
  }, []);

  return (
    <>
      <button
        type='button'
        ref={triggerRef}
        className={classes.handleHelpButton}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={accessibilityId}
      >
        <Icon
          id='help'
          icon={HelpIcon}
          aria-label={intl.formatMessage(messages.nameInfo)}
        />
      </button>

      <Overlay
        show={open}
        rootClose
        target={triggerRef}
        onHide={handleClick}
        offset={[5, 5]}
      >
        {({ props }) => (
          <div
            {...props}
            role='region'
            id={accessibilityId}
            className={classNames('dropdown-animation', classes.handleHelp)}
          >
            <FormattedMessage
              id='account.name.help.header'
              defaultMessage='A handle is like an email address'
              tagName='h3'
            />
            <ol>
              <li>
                <Icon id='at' icon={AtIcon} />
                {isSelf ? (
                  <FormattedMessage
                    id='account.name.help.username_self'
                    defaultMessage='{username} is your username on this server. Someone on another server might have the same username.'
                    values={{ username: <strong>{username}</strong> }}
                    tagName='p'
                  />
                ) : (
                  <FormattedMessage
                    id='account.name.help.username'
                    defaultMessage='{username} is this account’s username on their server. Someone on another server might have the same username.'
                    values={{ username: <strong>{username}</strong> }}
                    tagName='p'
                  />
                )}
              </li>
              <li>
                <Icon id='domain' icon={DomainIcon} />
                {isSelf ? (
                  <FormattedMessage
                    id='account.name.help.domain_self'
                    defaultMessage='{domain} is your server that hosts your profile and posts.'
                    values={{ domain: <strong>{domain}</strong> }}
                    tagName='p'
                  />
                ) : (
                  <FormattedMessage
                    id='account.name.help.domain'
                    defaultMessage='{domain} is the server that hosts the user’s profile and posts.'
                    values={{ domain: <strong>{domain}</strong> }}
                    tagName='p'
                  />
                )}
              </li>
            </ol>
            <FormattedMessage
              id='account.name.help.footer'
              defaultMessage='Just like you can send emails to people using different email clients, you can interact with people on other Mastodon servers – and with anyone on other social apps powered by the same set of rules as Mastodon uses (the ActivityPub protocol).'
              tagName='p'
            />
          </div>
        )}
      </Overlay>
    </>
  );
};
