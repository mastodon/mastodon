import type { PropsWithChildren } from 'react';
import { useCallback, useState, useEffect, useId } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { changeSetting } from 'mastodon/actions/settings';
import { bannerSettings } from 'mastodon/settings';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import {
  clearActiveOnboardingHint,
  setActiveOnboardingHint,
} from '../actions/onboarding_hints';

import { IconButton } from './icon_button';

function useIsActiveOnboardingHint({
  id,
  canBeDisplayed,
}: {
  id: string;
  canBeDisplayed: boolean;
}) {
  const dispatch = useAppDispatch();
  const activeOnboardingHintId = useAppSelector(
    (state) => state.onboardingHints.activeOnboardingHintId,
  );
  const uniqueId = useId();
  const hintId = `${id}-${uniqueId}`;

  const isActiveHint = activeOnboardingHintId === hintId;

  useEffect(() => {
    if (canBeDisplayed) {
      dispatch(setActiveOnboardingHint(hintId));
    }

    return () => {
      if (isActiveHint && !canBeDisplayed) {
        dispatch(clearActiveOnboardingHint());
      }
    };
  }, [canBeDisplayed, dispatch, hintId, isActiveHint]);

  return isActiveHint;
}

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

export function useDismissableBannerState({
  id,
  allowMultiple = false,
}: {
  id: string;
  /**
   * Set this to true to allow this banner to be displayed at the same time
   * as other banners or UI hints using this hook.
   */
  allowMultiple?: boolean;
}) {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  const dismissed: boolean = useAppSelector((state) =>
    /* eslint-disable-next-line */
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
      dispatch(changeSetting(['dismissed_banners', id], true));
    }
  }, [id, dispatch, isVisible, dismissed]);

  const isActiveOnboardingHint = useIsActiveOnboardingHint({
    id,
    canBeDisplayed: isVisible,
  });

  return {
    isVisible: allowMultiple ? isVisible : isVisible && isActiveOnboardingHint,
    dismiss,
  };
}

interface Props {
  id: string;
}

export const DismissableBanner: React.FC<PropsWithChildren<Props>> = ({
  id,
  children,
}) => {
  const intl = useIntl();
  const { isVisible, dismiss } = useDismissableBannerState({
    id,
    allowMultiple: true,
  });

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
