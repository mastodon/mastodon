import { FormattedMessage } from 'react-intl';

import { LoadingIndicator } from './loading_indicator';

interface Props {
  onClick: (event: React.MouseEvent) => void;
  disabled?: boolean;
  visible?: boolean;
  loading?: boolean;
}
export const LoadMore: React.FC<Props> = ({
  onClick,
  disabled,
  visible = true,
  loading = false,
}) => {
  return (
    <button
      type='button'
      className='load-more'
      disabled={disabled || loading || !visible}
      style={{ visibility: visible ? 'visible' : 'hidden' }}
      onClick={onClick}
    >
      {loading ? (
        <LoadingIndicator />
      ) : (
        <FormattedMessage id='status.load_more' defaultMessage='Load more' />
      )}
    </button>
  );
};
