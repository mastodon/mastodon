import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { useAccount } from '@/mastodon/hooks/useAccount';

import classes from '../styles.module.scss';

export const AccountListHeader: FC<{
  accountId: string;
  total?: number;
  titleText: MessageDescriptor;
}> = ({ accountId, total, titleText }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  return (
    <>
      <h2 className={classes.title}>
        {intl.formatMessage(titleText, {
          name: <DisplayNameSimple account={account} />,
        })}
      </h2>
      {!!total && (
        <h3 className={classes.subtitle}>
          <FormattedMessage
            id='account_list.total'
            defaultMessage='{total, plural, one {# account} other {# accounts}}'
            values={{ total }}
          />
        </h3>
      )}
    </>
  );
};
