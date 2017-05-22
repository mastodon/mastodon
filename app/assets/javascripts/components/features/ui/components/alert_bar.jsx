import { Link } from 'react-router';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

export default class AlertBar extends React.Component {

  render () {
    const { isEmailConfirmed } = this.props;

    return (
      <div className='alert-bar'>
        {
          (!isEmailConfirmed &&
            <div className='alert'>
              <i className='fa fa-fw fa-exclamation-triangle' /><FormattedMessage id='alert_bar.email_confirm_alert' defaultMessage='Your email address is not confirmed. Please confirm the sent email.' />
            </div>
          )
        }
      </div>
    );
  }

}

AlertBar.propTypes = {
  isEmailConfirmed: PropTypes.bool.isRequired,
};
