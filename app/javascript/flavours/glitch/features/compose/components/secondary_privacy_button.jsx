import PropTypes from 'prop-types';

import { useIntl, defineMessages } from 'react-intl';

import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import { Button } from 'flavours/glitch/components/button';
import { Icon } from 'flavours/glitch/components/icon';

const messages = defineMessages({
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Quiet public' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Specific people' },
});

export const SecondaryPrivacyButton = ({ disabled, privacy, isEditing, onClick }) => {
  const intl = useIntl();

  if (isEditing || !privacy || privacy === 'none') {
    return null;
  }

  const privacyProps = {
    direct: { icon: 'envelope', iconComponent: MailIcon, title: messages.direct },
    private: { icon: 'lock', iconComponent: LockIcon, title: messages.private },
    public: { icon: 'globe', iconComponent: PublicIcon, title: messages.public },
    unlisted: { icon: 'unlock', iconComponent: QuietTimeIcon, title: messages.unlisted },
  };

  return (
    <Button className='secondary-post-button' disabled={disabled} onClick={onClick} title={intl.formatMessage(privacyProps[privacy].title)}>
      <Icon id={privacyProps[privacy].id} icon={privacyProps[privacy].iconComponent} />
    </Button>
  );
};

SecondaryPrivacyButton.propTypes = {
  disabled: PropTypes.bool,
  privacy: PropTypes.string,
  isEditing: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
};
