//  Package imports  //
import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';

import { Icon } from 'flavours/glitch/components/icon';

const messages = defineMessages({
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Mentioned people only' },
});

class VisibilityIcon extends ImmutablePureComponent {

  static propTypes = {
    visibility: PropTypes.string,
    intl: PropTypes.object.isRequired,
    withLabel: PropTypes.bool,
  };

  render() {
    const { withLabel, visibility, intl } = this.props;

    const visibilityIcon = {
      public: 'globe',
      unlisted: 'unlock',
      private: 'lock',
      direct: 'envelope',
    }[visibility];

    const label = intl.formatMessage(messages[visibility]);

    const icon = (<Icon
      className='status__visibility-icon'
      fixedWidth
      id={visibilityIcon}
      title={label}
      aria-hidden='true'
    />);

    if (withLabel) {
      return (<span style={{ whiteSpace: 'nowrap' }}>{icon} {label}</span>);
    } else {
      return icon;
    }
  }

}

export default injectIntl(VisibilityIcon);
