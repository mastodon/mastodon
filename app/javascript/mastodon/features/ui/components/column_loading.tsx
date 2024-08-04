import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import type { Props as ColumnHeaderProps } from 'mastodon/components/column_header';

export const ColumnLoading: React.FC<ColumnHeaderProps> = (otherProps) => (
  <Column>
    <ColumnHeader {...otherProps} />
    <div className='scrollable' />
  </Column>
);
