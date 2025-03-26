import { MouseEventHandler } from 'react';
import { FormattedMessage } from 'react-intl';

interface Props {
  onClick: MouseEventHandler<HTMLButtonElement>;
}

const GrantPermissionButton: React.FC<Props> = ({ onClick }) => {
  return (
    <button
      className='text-btn column-header__permission-btn'
      tabIndex={0}
      onClick={onClick}
    >
      <FormattedMessage
        id='notifications.grant_permission'
        defaultMessage='Grant permission.'
      />
    </button>
  );
};

export default GrantPermissionButton;
