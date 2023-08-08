import { FormattedMessage } from 'react-intl';

interface Props {
  onMouseDown: (event: React.MouseEvent) => void;
  onMouseUp: (event: React.MouseEvent) => void;
  count: number;
}

export const LoadPending: React.FC<Props> = ({
  onMouseDown,
  onMouseUp,
  count,
}) => {
  return (
    <button
      className='load-more load-gap'
      onMouseDown={onMouseDown}
      onMouseUp={onMouseUp}
    >
      <FormattedMessage
        id='load_pending'
        defaultMessage='{count, plural, one {# new item} other {# new items}}'
        values={{ count }}
      />
    </button>
  );
};
