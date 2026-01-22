import type { FC } from 'react';

import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { selectTimelineByParams } from '@/mastodon/selectors/timelines';
import { useAppSelector } from '@/mastodon/store';

const AccountTimelineV2: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const timeline = useAppSelector((state) =>
    selectTimelineByParams(state, { type: 'account', userId: accountId ?? '' }),
  );

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!timeline) {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  }

  return (
    <Column>
      <ColumnBackButton />
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountTimelineV2;
