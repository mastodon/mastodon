import React from 'react';
import IconButton from './icon_button';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import { bannerSettings } from 'flavours/glitch/settings';

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

export default @injectIntl
class DismissableBanner extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    children: PropTypes.node,
    intl: PropTypes.object.isRequired,
  };

  state = {
    visible: !bannerSettings.get(this.props.id),
  };

  handleDismiss = () => {
    const { id } = this.props;
    this.setState({ visible: false }, () => bannerSettings.set(id, true));
  };

  render () {
    const { visible } = this.state;

    if (!visible) {
      return null;
    }

    const { children, intl } = this.props;

    return (
      <div className='dismissable-banner'>
        <div className='dismissable-banner__message'>
          {children}
        </div>

        <div className='dismissable-banner__action'>
          <IconButton icon='times' title={intl.formatMessage(messages.dismiss)} onClick={this.handleDismiss} />
        </div>
      </div>
    );
  }

}
