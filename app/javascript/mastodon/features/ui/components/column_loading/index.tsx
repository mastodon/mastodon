import { FormattedMessage } from 'react-intl';

import { CircularProgress } from '@/mastodon/components/circular_progress';
import { Column } from '@/mastodon/components/column';
import type { ColumnHeaderProps } from '@/mastodon/components/column/header';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { Skeleton } from '@/mastodon/components/skeleton';

import classes from './styles.module.scss';

export const ColumnLoading: React.FC<ColumnHeaderProps> = () => (
  <Column>
    <ColumnHeader title={<Skeleton width='120px' />} />

    <div className='scrollable'>
      <div className={classes.loadingWrapper}>
        <CircularProgress size={30} strokeWidth={2} />
        <FormattedMessage
          id='loading_indicator.label'
          defaultMessage='Loading…'
        />
      </div>
    </div>
  </Column>
);
