import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from '@/mastodon/components/button';
import { Column } from '@/mastodon/components/column';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';

import classes from './styles.module.scss';

export const AccountEdit: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useCurrentAccountId();

  if (!accountId) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column bindToDocument={!multiColumn} className={classes.column}>
      <header>
        <div className={classes.nav}>
          <FormattedMessage
            id='account_edit.column_title'
            defaultMessage='Edit Profile'
            tagName='h1'
          />
          <Button>
            <FormattedMessage
              id='account_edit.column_button'
              defaultMessage='Done'
            />
          </Button>
        </div>
      </header>
    </Column>
  );
};
