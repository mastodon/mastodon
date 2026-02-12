import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconVerified from '@/images/icons/icon_verified.svg?react';
import { AccountFields } from '@/mastodon/components/account_fields';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { Icon } from '@/mastodon/components/icon';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import type { Account } from '@/mastodon/models/account';
import { isValidUrl } from '@/mastodon/utils/checks';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountHeaderFields: FC<{ accountId: string }> = ({
  accountId,
}) => {
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  if (isRedesignEnabled()) {
    return <RedesignAccountHeaderFields account={account} />;
  }

  return (
    <div className='account__header__fields'>
      <dl>
        <dt>
          <FormattedMessage id='account.joined_short' defaultMessage='Joined' />
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

      <AccountFields fields={account.fields} emojis={account.emojis} />
    </div>
  );
};

const RedesignAccountHeaderFields: FC<{ account: Account }> = ({ account }) => {
  const htmlHandlers = useElementHandledLink();

  return (
    <dl className={classes.fieldList}>
      {account.fields.map(
        (
          { name, name_emojified, value_emojified, value_plain, verified_at },
          key,
        ) => (
          <div
            key={key}
            className={classNames(
              classes.fieldRow,
              verified_at && classes.fieldVerified,
            )}
          >
            <EmojiHTML
              htmlString={name_emojified}
              extraEmojis={account.emojis}
              className={classNames(
                'translate',
                isValidUrl(name) && classes.fieldLink,
              )}
              as='dt'
              title={showTitleOnLength(name, 50)}
              {...htmlHandlers}
            />
            <EmojiHTML
              as='dd'
              htmlString={value_emojified}
              extraEmojis={account.emojis}
              title={showTitleOnLength(value_plain, 120)}
              className={classNames(
                value_plain && isValidUrl(value_plain) && classes.fieldLink,
              )}
              {...htmlHandlers}
            />
            {verified_at && (
              <Icon
                id='verified'
                icon={IconVerified}
                className={classes.fieldVerifiedIcon}
                noFill
              />
            )}
          </div>
        ),
      )}
    </dl>
  );
};

function showTitleOnLength(value: string | null, maxLength: number) {
  if (value && value.length > maxLength) {
    return value;
  }
  return undefined;
}
