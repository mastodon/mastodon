import { FormattedMessage } from 'react-intl';

interface Props {
  onClick: (event: React.MouseEvent) => void;
  count: number;
}

export const LoadPending: React.FC<Props> = ({ onClick, count }) => {
  return (
    <button className='load-more load-gap' onClick={onClick} type='button'>
      <FormattedMessage
        id='load_pending'
        defaultMessage='{count, plural, one {# new item} other {# new items}}'
        values={{ count }}
      />
    </button>
  );
};
