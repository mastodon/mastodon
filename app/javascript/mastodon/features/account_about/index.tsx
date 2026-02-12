import type { FC } from 'react';

import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';

export const AccountAbout: FC = () => {
  return (
    <Column>
      <ColumnBackButton />
      <div>Account About</div>
    </Column>
  );
};
