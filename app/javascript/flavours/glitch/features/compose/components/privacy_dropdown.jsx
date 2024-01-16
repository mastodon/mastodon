import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import LockOpenIcon from '@/material-icons/400-24px/lock_open.svg?react';
import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';

import Dropdown from './dropdown';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  public_long: { id: 'privacy.public.long', defaultMessage: 'Visible for all' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  unlisted_long: { id: 'privacy.unlisted.long', defaultMessage: 'Visible for all, but opted-out of discovery features' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers only' },
  private_long: { id: 'privacy.private.long', defaultMessage: 'Visible for followers only' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Mentioned people only' },
  direct_long: { id: 'privacy.direct.long', defaultMessage: 'Visible for mentioned users only' },
  change_privacy: { id: 'privacy.change', defaultMessage: 'Adjust status privacy' },
});

class PrivacyDropdown extends PureComponent {

  static propTypes = {
    isUserTouching: PropTypes.func,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    value: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    noDirect: PropTypes.bool,
    container: PropTypes.func,
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { value, onChange, onModalOpen, onModalClose, disabled, noDirect, container, isUserTouching, intl: { formatMessage } } = this.props;

    //  We predefine our privacy items so that we can easily pick the
    //  dropdown icon later.
    const privacyItems = {
      direct: {
        icon: 'envelope',
        iconComponent: MailIcon,
        meta: formatMessage(messages.direct_long),
        name: 'direct',
        text: formatMessage(messages.direct_short),
      },
      private: {
        icon: 'lock',
        iconComponent: LockIcon,
        meta: formatMessage(messages.private_long),
        name: 'private',
        text: formatMessage(messages.private_short),
      },
      public: {
        icon: 'globe',
        iconComponent: PublicIcon,
        meta: formatMessage(messages.public_long),
        name: 'public',
        text: formatMessage(messages.public_short),
      },
      unlisted: {
        icon: 'unlock',
        iconComponent: LockOpenIcon,
        meta: formatMessage(messages.unlisted_long),
        name: 'unlisted',
        text: formatMessage(messages.unlisted_short),
      },
    };

    const items = [privacyItems.public, privacyItems.unlisted, privacyItems.private];

    if (!noDirect) {
      items.push(privacyItems.direct);
    }

    return (
      <Dropdown
        disabled={disabled}
        icon={(privacyItems[value] || {}).icon}
        iconComponent={(privacyItems[value] || {}).iconComponent}
        items={items}
        onChange={onChange}
        isUserTouching={isUserTouching}
        onModalClose={onModalClose}
        onModalOpen={onModalOpen}
        title={formatMessage(messages.change_privacy)}
        container={container}
        value={value}
      />
    );
  }

}

export default injectIntl(PrivacyDropdown);
