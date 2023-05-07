import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { preferenceLink } from 'flavours/glitch/utils/backend_links';
import Button from 'flavours/glitch/components/button';
import Icon from 'flavours/glitch/components/icon';
import illustration from 'flavours/glitch/images/logo_warn_glitch.svg';

const messages = defineMessages({
  discardChanges: { id: 'confirmations.deprecated_settings.confirm', defaultMessage: 'Use Mastodon preferences' },
  user_setting_expand_spoilers: { id: 'settings.enable_content_warnings_auto_unfold', defaultMessage: 'Automatically unfold content-warnings' },
  user_setting_disable_swiping: { id: 'settings.swipe_to_change_columns', defaultMessage: 'Allow swiping to change columns (Mobile only)' },
});

class DeprecatedSettingsModal extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.list.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleClick = () => {
    this.props.onConfirm();
    this.props.onClose();
  };

  setRef = (c) => {
    this.button = c;
  };

  render () {
    const { settings, intl } = this.props;

    return (
      <div className='modal-root__modal confirmation-modal'>
        <div className='confirmation-modal__container'>

          <img src={illustration} className='modal-warning' alt='' />

          <FormattedMessage
            id='confirmations.deprecated_settings.message'
            defaultMessage='Some of the glitch-soc device-specific {app_settings} you are using have been replaced by Mastodon {preferences} and will be overriden:'
            values={{
              app_settings: (
                <strong className='deprecated-settings-label'>
                  <Icon id='cogs' /> <FormattedMessage id='navigation_bar.app_settings' defaultMessage='App settings' />
                </strong>
              ),
              preferences: (
                <strong className='deprecated-settings-label'>
                  <Icon id='cog' /> <FormattedMessage id='navigation_bar.preferences' defaultMessage='Preferences' />
                </strong>
              ),
            }}
          />

          <div className='deprecated-settings-info'>
            <ul>
              { settings.map((setting_name) => (
                <li key={setting_name}>
                  <a href={preferenceLink(setting_name)}><FormattedMessage {...messages[setting_name]} /></a>
                </li>
              )) }
            </ul>
          </div>
        </div>

        <div>
          <div className='confirmation-modal__action-bar'>
            <div />
            <Button text={intl.formatMessage(messages.discardChanges)} onClick={this.handleClick} ref={this.setRef} />
          </div>
        </div>
      </div>
    );
  }

}

export default injectIntl(DeprecatedSettingsModal);
