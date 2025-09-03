/* eslint-disable @typescript-eslint/no-unsafe-call,
                  @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access
                  -- the settings store is not yet typed */
import type { PropsWithChildren } from 'react';
import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { changeSetting } from 'mastodon/actions/settings';
import { bannerSettings } from 'mastodon/settings';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { IconButton } from './icon_button';

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

interface Props {
  id: string;
}

export function useDismissableBannerState(id: string) {
  const dismissed = useAppSelector((state) =>
    state.settings.getIn(['dismissed_banners', id], false),
  );

  const [isVisible, setIsVisible] = useState(
    !bannerSettings.get(id) && !dismissed,
  );

  const dispatch = useAppDispatch();

  const dismiss = useCallback(() => {
    setIsVisible(false);
    bannerSettings.set(id, true);
    dispatch(changeSetting(['dismissed_banners', id], true));
  }, [id, dispatch]);

  useEffect(() => {
    if (!isVisible && !dismissed) {
      // dispatch(changeSetting(['dismissed_banners', id], true));
    }
  }, [id, dispatch, isVisible, dismissed]);

  return { isVisible, dismiss };
}

export const DismissableBanner: React.FC<PropsWithChildren<Props>> = ({
  id,
  children,
}) => {
  const intl = useIntl();
  const { isVisible, dismiss } = useDismissableBannerState(id);

  if (!isVisible) {
    return null;
  }

  return (
    <div className='dismissable-banner'>
      <div className='dismissable-banner__action'>
        <IconButton
          icon='times'
          iconComponent={CloseIcon}
          title={intl.formatMessage(messages.dismiss)}
          onClick={dismiss}
        />
      </div>

      <div className='dismissable-banner__message'>{children}</div>
    </div>
  );
};
