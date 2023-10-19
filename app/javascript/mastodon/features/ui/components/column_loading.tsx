import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';

export const ColumnLoading: React.FC = () => (
  <Column>
    <ColumnHeader />
    <div className='scrollable' />
  </Column>
);
