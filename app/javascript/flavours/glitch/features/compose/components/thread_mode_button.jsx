import { useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import QuickreplyIcon from '@/material-icons/400-20px/quickreply.svg?react';
import { changeComposeAdvancedOption } from 'flavours/glitch/actions/compose';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

const messages = defineMessages({
  enable_threaded_mode: { id: 'compose.enable_threaded_mode', defaultMessage: 'Enable threaded mode' },
  disable_threaded_mode: { id: 'compose.disable_threaded_mode', defaultMessage: 'Disable threaded mode' },
});

export const ThreadModeButton = () => {
  const intl = useIntl();

  const isEditing = useAppSelector((state) => state.getIn(['compose', 'id']) !== null);
  const active = useAppSelector((state) => state.getIn(['compose', 'advanced_options', 'threaded_mode']));

  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(changeComposeAdvancedOption('threaded_mode', !active));
  }, [active, dispatch]);

  const title = intl.formatMessage(active ? messages.disable_threaded_mode : messages.enable_threaded_mode);

  return (
    <IconButton
      disabled={isEditing}
      icon=''
      onClick={handleClick}
      iconComponent={QuickreplyIcon}
      title={title}
      active={active}
      size={18}
      inverted
    />
  );
};
