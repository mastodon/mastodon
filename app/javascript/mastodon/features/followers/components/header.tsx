import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { Callout } from '@/mastodon/components/callout';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';

import classes from '../styles.module.scss';

export const AccountListHeader: FC<{
  accountId: string;
  total?: number;
}> = ({ accountId, total }) => {
  const account = useAccount(accountId);
  const currentId = useCurrentAccountId();
  return (
    <>
      {!!total && (
        <h2 className={classes.subtitle}>
          <FormattedMessage
            id='account_list.total'
            defaultMessage='{total, plural, one {# account} other {# accounts}}'
            values={{ total }}
          />
        </h2>
      )}
      {accountId === currentId && account?.hide_collections && (
        <Callout className={classes.callout}>
          <FormattedMessage
            id='account_list.hidden_notice'
            defaultMessage='This is only visible to you. To show this list to others, go to <link>{page} > {modal} > {field}</link>.'
            values={{
              link: (chunks) => <Link to='/profile/edit'>{chunks}</Link>,
              page: (
                <FormattedMessage
                  id='account.edit_profile'
                  defaultMessage='Edit profile'
                />
              ),
              modal: (
                <FormattedMessage
                  id='account_edit.profile_tab.title'
                  defaultMessage='Profile display settings'
                />
              ),
              field: (
                <FormattedMessage
                  id='account_edit.profile_tab.show_relations.title'
                  defaultMessage='Show ‘Followers’ and ‘Following’'
                />
              ),
            }}
          />
        </Callout>
      )}
    </>
  );
};
