import { defineMessages, useIntl } from 'react-intl';

import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import type { StatusVisibility } from 'flavours/glitch/models/status';

import { Icon } from './icon';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: {
    id: 'privacy.unlisted.short',
    defaultMessage: 'Quiet public',
  },
  private_short: {
    id: 'privacy.private.short',
    defaultMessage: 'Followers',
  },
  direct_short: {
    id: 'privacy.direct.short',
    defaultMessage: 'Specific people',
  },
});

export const VisibilityIcon: React.FC<{ visibility: StatusVisibility }> = ({
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
      iconComponent: QuietTimeIcon,
      text: intl.formatMessage(messages.unlisted_short),
    },
    private: {
      icon: 'lock',
      iconComponent: LockIcon,
      text: intl.formatMessage(messages.private_short),
    },
    direct: {
      icon: 'envelope',
      iconComponent: MailIcon,
      text: intl.formatMessage(messages.direct_short),
    },
  };

  const visibilityIcon = visibilityIconInfo[visibility];

  return (
    <Icon
      id={visibilityIcon.icon}
      icon={visibilityIcon.iconComponent}
      title={visibilityIcon.text}
      className={'status__visibility-icon'}
    />
  );
};
