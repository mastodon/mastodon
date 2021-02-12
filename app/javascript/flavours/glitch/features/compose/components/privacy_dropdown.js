import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import Dropdown from './dropdown';

const messages = defineMessages({
  change_privacy: {
    defaultMessage: 'Adjust status privacy',
    id: 'privacy.change',
  },
  direct_long: {
    defaultMessage: 'Visible for mentioned users only',
    id: 'privacy.direct.long',
  },
  direct_short: {
    defaultMessage: 'Direct',
    id: 'privacy.direct.short',
  },
  private_long: {
    defaultMessage: 'Visible for followers only',
    id: 'privacy.private.long',
  },
  private_short: {
    defaultMessage: 'Followers-only',
    id: 'privacy.private.short',
  },
  public_long: {
    defaultMessage: 'Visible for all, shown in public timelines',
    id: 'privacy.public.long',
  },
  public_short: {
    defaultMessage: 'Public',
    id: 'privacy.public.short',
  },
  unlisted_long: {
    defaultMessage: 'Visible for all, but not in public timelines',
    id: 'privacy.unlisted.long',
  },
  unlisted_short: {
    defaultMessage: 'Unlisted',
    id: 'privacy.unlisted.short',
  },
});

export default @injectIntl
class PrivacyDropdown extends React.PureComponent {

  static propTypes = {
    isUserTouching: PropTypes.func,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    value: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    noDirect: PropTypes.bool,
    noModal: PropTypes.bool,
    container: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { value, onChange, onModalOpen, onModalClose, disabled, noDirect, noModal, container, intl } = this.props;

    //  We predefine our privacy items so that we can easily pick the
    //  dropdown icon later.
    const privacyItems = {
      direct: {
        icon: 'envelope',
        meta: <FormattedMessage {...messages.direct_long} />,
        name: 'direct',
        text: <FormattedMessage {...messages.direct_short} />,
      },
      private: {
        icon: 'lock',
        meta: <FormattedMessage {...messages.private_long} />,
        name: 'private',
        text: <FormattedMessage {...messages.private_short} />,
      },
      public: {
        icon: 'globe',
        meta: <FormattedMessage {...messages.public_long} />,
        name: 'public',
        text: <FormattedMessage {...messages.public_short} />,
      },
      unlisted: {
        icon: 'unlock',
        meta: <FormattedMessage {...messages.unlisted_long} />,
        name: 'unlisted',
        text: <FormattedMessage {...messages.unlisted_short} />,
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
        onModalClose={onModalClose}
        onModalOpen={onModalOpen}
        title={intl.formatMessage(messages.change_privacy)}
        container={container}
        noModal={noModal}
        value={value}
      />
    );
  }

}
