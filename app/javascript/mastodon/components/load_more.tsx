import { FormattedMessage } from 'react-intl';

interface Props {
  onMouseDown: (event: React.MouseEvent) => void;
  onMouseUp: (event: React.MouseEvent) => void;
  disabled?: boolean;
  visible?: boolean;
}
export const LoadMore: React.FC<Props> = ({
  onMouseDown,
  onMouseUp,
  disabled,
  visible = true,
}) => {
  return (
    <button
      type='button'
      className='load-more'
      disabled={disabled || !visible}
      style={{ visibility: visible ? 'visible' : 'hidden' }}
      onMouseDown={onMouseDown}
      onMouseUp={onMouseUp}
    >
      <FormattedMessage id='status.load_more' defaultMessage='Load more' />
    </button>
  );
};
