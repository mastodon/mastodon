import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';

interface Props {
  multiColumn?: boolean;
}

export const ColumnLoading: React.FC<Props> = (otherProps) => (
  <Column>
    <ColumnHeader {...otherProps} />
    <div className='scrollable' />
  </Column>
);
