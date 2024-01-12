import { defineMessages, useIntl } from 'react-intl';

import AlternateEmailIcon from '@material-symbols/svg-600/outlined/alternate_email.svg?react';
import LockIcon from '@material-symbols/svg-600/outlined/lock.svg?react';
import LockOpenIcon from '@material-symbols/svg-600/outlined/lock_open.svg?react';
import PublicIcon from '@material-symbols/svg-600/outlined/public.svg?react';

import { Icon } from './icon';

type Visibility = 'public' | 'unlisted' | 'private' | 'direct';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private_short: {
    id: 'privacy.private.short',
    defaultMessage: 'Followers only',
  },
  direct_short: {
    id: 'privacy.direct.short',
    defaultMessage: 'Mentioned people only',
  },
});

export const VisibilityIcon: React.FC<{ visibility: Visibility }> = ({
  visibility,
}) => {
  const intl = useIntl();

  const visibilityIconInfo = {
    public: {
      icon: 'globe',
      iconComponent: PublicIcon,
      text: intl.formatMessage(messages.public_short),
    },
    unlisted: {
      icon: 'unlock',
      iconComponent: LockOpenIcon,
      text: intl.formatMessage(messages.unlisted_short),
    },
    private: {
      icon: 'lock',
      iconComponent: LockIcon,
      text: intl.formatMessage(messages.private_short),
    },
    direct: {
      icon: 'at',
      iconComponent: AlternateEmailIcon,
      text: intl.formatMessage(messages.direct_short),
    },
  };

  const visibilityIcon = visibilityIconInfo[visibility];

  return (
    <Icon
      id={visibilityIcon.icon}
      icon={visibilityIcon.iconComponent}
      title={visibilityIcon.text}
    />
  );
};
