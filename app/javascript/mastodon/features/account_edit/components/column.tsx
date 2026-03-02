import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';

import { useColumnsContext } from '../../ui/util/columns_context';
import classes from '../styles.module.scss';

export const AccountEditEmptyColumn: FC<{
  notFound?: boolean;
}> = ({ notFound }) => {
  const { multiColumn } = useColumnsContext();

  if (notFound) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column bindToDocument={!multiColumn} className={classes.column}>
      <LoadingIndicator />
    </Column>
  );
};

export const AccountEditColumn: FC<{
  title: string;
  to: string;
  children: React.ReactNode;
}> = ({ to, title, children }) => {
  const { multiColumn } = useColumnsContext();

  return (
    <Column bindToDocument={!multiColumn} className={classes.column}>
      <ColumnHeader
        title={title}
        className={classes.columnHeader}
        showBackButton
        extraButton={
          <Link to={to} className='button'>
            <FormattedMessage
              id='account_edit.column_button'
              defaultMessage='Done'
            />
          </Link>
        }
      />

      {children}
    </Column>
  );
};
