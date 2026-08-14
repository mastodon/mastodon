import { FormattedMessage } from 'react-intl';

import { DotsThreeIcon } from '@phosphor-icons/react';

import { Account } from '@/mastodon/components/account';
import { IconButton } from '@/mastodon/components/button/redesign';
import { useIdentity } from '@/mastodon/identity_context';

import classes from './account_card.module.scss';

export const NavigationAccountCard: React.FC = () => {
  const { accountId } = useIdentity();

  if (!accountId) {
    return null;
  }

  return (
    <div className={classes.root}>
      <Account
        id={accountId}
        minimal
        withBorder={false}
        withMenu={false}
        size={32}
      />
      <IconButton as='button' icon={DotsThreeIcon} variant='ghost' size='sm'>
        <FormattedMessage id='tabs_bar.more' defaultMessage='More' />
      </IconButton>
    </div>
  );
};
