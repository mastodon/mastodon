import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { CheckIcon } from '@phosphor-icons/react';
import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import {
  ColumnHeader,
  ColumnHeaderButton,
} from '@/mastodon/components/column_header';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { BundleColumnError } from '@/mastodon/features/ui/components/bundle_column_error';

import { useColumnsContext } from '../../ui/util/columns_context';

export const AccountEditEmptyColumn: FC<{
  notFound?: boolean;
}> = ({ notFound }) => {
  const { multiColumn } = useColumnsContext();

  if (notFound) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column bindToDocument={!multiColumn}>
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
    <>
      <Column bindToDocument={!multiColumn}>
        <ColumnHeader
          withBackButton
          title={title}
          extraButtons={
            <ColumnHeaderButton
              showTextOnDesktop
              variant='solid'
              color='accent'
              as='link'
              to={to}
              icon={CheckIcon}
            >
              <FormattedMessage
                id='account_edit.column_button'
                defaultMessage='Done'
              />
            </ColumnHeaderButton>
          }
        />
        <div className='scrollable'>{children}</div>
      </Column>
      <Helmet>
        <title>{title}</title>
      </Helmet>
    </>
  );
};
