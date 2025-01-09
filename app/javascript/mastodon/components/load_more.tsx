import { FormattedMessage } from 'react-intl';

interface Props {
  onClick: (event: React.MouseEvent) => void;
  disabled?: boolean;
  visible?: boolean;
}
export const LoadMore: React.FC<Props> = ({
  onClick,
  disabled,
  visible = true,
}) => {
  return (
    <button
      type='button'
      className='load-more'
      disabled={disabled || !visible}
      style={{ visibility: visible ? 'visible' : 'hidden' }}
      onClick={onClick}
    >
      <FormattedMessage id='status.load_more' defaultMessage='Load more' />
    </button>
  );
};
