import type { PropsWithChildren } from 'react';
import { useCallback, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { bannerSettings } from 'mastodon/settings';

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
  const [visible, setVisible] = useState(!bannerSettings.get(id));
  const intl = useIntl();

  const handleDismiss = useCallback(() => {
    setVisible(false);
    bannerSettings.set(id, true);
  }, [id]);

  if (!visible) {
    return null;
  }

  return (
    <div className='dismissable-banner'>
      <div className='dismissable-banner__action'>
        <IconButton
          icon='times'
          title={intl.formatMessage(messages.dismiss)}
          onClick={handleDismiss}
        />
      </div>

      <div className='dismissable-banner__message'>{children}</div>
    </div>
  );
};
