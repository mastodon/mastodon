/* eslint-disable @typescript-eslint/no-unsafe-call,
                  @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access
                  -- the settings store is not yet typed */
import type { PropsWithChildren } from 'react';
import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { changeSetting } from 'flavours/glitch/actions/settings';
import { bannerSettings } from 'flavours/glitch/settings';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import { IconButton } from './icon_button';

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

interface Props {
  id: string;
}

export const DismissableBanner: React.FC<PropsWithChildren<Props>> = ({
  id,
  children,
}) => {
  const dismissed = useAppSelector((state) =>
    state.settings.getIn(['dismissed_banners', id], false),
  );
  const dispatch = useAppDispatch();

  const [visible, setVisible] = useState(!bannerSettings.get(id) && !dismissed);
  const intl = useIntl();

  const handleDismiss = useCallback(() => {
    setVisible(false);
    bannerSettings.set(id, true);
    dispatch(changeSetting(['dismissed_banners', id], true));
  }, [id, dispatch]);

  useEffect(() => {
    if (!visible && !dismissed) {
      dispatch(changeSetting(['dismissed_banners', id], true));
    }
  }, [id, dispatch, visible, dismissed]);

  if (!visible) {
    return null;
  }

  return (
    <div className='dismissable-banner'>
      <div className='dismissable-banner__action'>
        <IconButton
          icon='times'
          iconComponent={CloseIcon}
          title={intl.formatMessage(messages.dismiss)}
          onClick={handleDismiss}
        />
      </div>

      <div className='dismissable-banner__message'>{children}</div>
    </div>
  );
};
