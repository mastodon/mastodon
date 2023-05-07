import PropTypes from 'prop-types';
import React from 'react';
import { defineMessages, injectIntl } from 'react-intl';
import Dropdown from './dropdown';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  public_long: { id: 'privacy.public.long', defaultMessage: 'Visible for all' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  unlisted_long: { id: 'privacy.unlisted.long', defaultMessage: 'Visible for all, but opted-out of discovery features' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers only' },
  private_long: { id: 'privacy.private.long', defaultMessage: 'Visible for followers only' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Only people I mention' },
  direct_long: { id: 'privacy.direct.long', defaultMessage: 'Visible for mentioned users only' },
  change_privacy: { id: 'privacy.change', defaultMessage: 'Adjust status privacy' },
});

class PrivacyDropdown extends React.PureComponent {

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
        meta: formatMessage(messages.direct_long),
        name: 'direct',
        text: formatMessage(messages.direct_short),
      },
      private: {
        icon: 'lock',
        meta: formatMessage(messages.private_long),
        name: 'private',
        text: formatMessage(messages.private_short),
      },
      public: {
        icon: 'globe',
        meta: formatMessage(messages.public_long),
        name: 'public',
        text: formatMessage(messages.public_short),
      },
      unlisted: {
        icon: 'unlock',
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
