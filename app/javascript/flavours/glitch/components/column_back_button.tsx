import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import ArrowBackIcon from '@/material-icons/400-24px/arrow_back.svg?react';
import { Icon } from 'flavours/glitch/components/icon';
import { getColumnSkipLinkId } from 'flavours/glitch/features/ui/components/skip_links';
import { ButtonInTabsBar } from 'flavours/glitch/features/ui/util/columns_context';

import { useColumnIndexContext } from '../features/ui/components/columns_area';

import { useAppHistory } from './router';

type OnClickCallback = () => void;

function useHandleClick(onClick?: OnClickCallback) {
  const history = useAppHistory();

  return useCallback(() => {
    if (onClick) {
      onClick();
    } else if (history.location.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history, onClick]);
}

export const ColumnBackButton: React.FC<{ onClick?: OnClickCallback }> = ({
  onClick,
}) => {
  const handleClick = useHandleClick(onClick);
  const columnIndex = useColumnIndexContext();

  const component = (
    <button
      onClick={handleClick}
      id={getColumnSkipLinkId(columnIndex)}
      className='column-back-button'
      type='button'
    >
      <Icon
        id='chevron-left'
        icon={ArrowBackIcon}
        className='column-back-button__icon'
      />
      <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
    </button>
  );

  return <ButtonInTabsBar>{component}</ButtonInTabsBar>;
};
