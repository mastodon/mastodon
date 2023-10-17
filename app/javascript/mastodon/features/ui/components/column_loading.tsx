import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';

export const ColumnLoading: React.FC<{ multiColumn?: boolean }> = ({
  multiColumn,
}) => (
  <Column>
    <ColumnHeader multiColumn={multiColumn} focusable={false} placeholder />
    <div className='scrollable' />
  </Column>
);
