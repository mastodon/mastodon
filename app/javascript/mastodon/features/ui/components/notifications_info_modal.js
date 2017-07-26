import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  title: { id: 'notifications_info_modal.title', defaultMessage: 'Notification types' },
  desktop_notifications_title: { id: 'notifications_info_modal.desktop_notifications_title', defaultMessage: 'Desktop notifications' },
  push_notifications_title: { id: 'notifications_info_modal.push_notifications_title', defaultMessage: 'Push notifications' },
  feature_work_on_mobile: { id: 'notifications_info_modal.feature_work_on_mobile', defaultMessage: 'Work on supported mobile devices *' },
  feature_work_when_tab_closed: { id: 'notifications_info_modal.feature_work_when_tab_closed', defaultMessage: 'Work when the tab is closed' },
  feature_configurable_per_device: { id: 'notifications_info_modal.feature_configurable_per_device', defaultMessage: 'Configurable on a per device basis' },
  supported_devices: { id: 'notifications_info_modal.supported_devices', defaultMessage: '* Google Chrome and Firefox on Android' },
  close: { id: 'notifications_info_modal.close', defaultMessage: 'Close' },
});

@injectIntl
class BundleModalError extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    onClose: PropTypes.func.isRequired,
  }

  render () {
    const { onClose, intl: { formatMessage } }  = this.props;

    return (
      <div className='modal-root__modal notifications-info-modal'>
        <FormattedMessage tagName='h1' {...messages.title} />

        <div className='notifications-info-modal__body'>
          <FormattedMessage tagName='h2' {...messages.push_notifications_title} />

          <ol>
            <li>
              <IconButton title={formatMessage(messages.feature_work_on_mobile)} icon='check' />
              <FormattedMessage {...messages.feature_work_on_mobile} />
            </li>
            <li>
              <IconButton title={formatMessage(messages.feature_work_when_tab_closed)} icon='check' />
              <FormattedMessage {...messages.feature_work_when_tab_closed} />
            </li>
            <li>
              <IconButton title={formatMessage(messages.feature_configurable_per_device)} icon='check' />
              <FormattedMessage {...messages.feature_configurable_per_device} />
            </li>
          </ol>

          <FormattedMessage tagName='h2' {...messages.desktop_notifications_title} />

          <ol>
            <li>
              <IconButton title={formatMessage(messages.feature_work_on_mobile)} icon='ban' />
              <FormattedMessage {...messages.feature_work_on_mobile} />
            </li>
            <li>
              <IconButton title={formatMessage(messages.feature_work_when_tab_closed)} icon='ban' />
              <FormattedMessage {...messages.feature_work_when_tab_closed} />
            </li>
            <li>
              <IconButton title={formatMessage(messages.feature_configurable_per_device)} icon='ban' />
              <FormattedMessage {...messages.feature_configurable_per_device} />
            </li>
          </ol>
        </div>

        <div className='notifications-info-modal__footer'>
          <FormattedMessage tagName='div' {...messages.supported_devices} />

          <div>
            <button onClick={onClose} className='notifications-info-modal__nav onboarding-modal__skip'>
              <FormattedMessage {...messages.close} />
            </button>
          </div>
        </div>
      </div>
    );
  }

}

export default BundleModalError;
