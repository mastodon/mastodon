import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column/header';
import type { ColumnHeaderProps } from '@/mastodon/components/column/header';

export const ColumnLoading: React.FC<ColumnHeaderProps> = (otherProps) => (
  <Column>
    <ColumnHeader {...otherProps} />
    <div className='scrollable' />
  </Column>
);
