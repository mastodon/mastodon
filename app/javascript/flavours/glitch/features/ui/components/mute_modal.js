import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import Button from 'flavours/glitch/components/button';
import { closeModal } from 'flavours/glitch/actions/modal';
import { muteAccount } from 'flavours/glitch/actions/accounts';
import { toggleHideNotifications } from 'flavours/glitch/actions/mutes';


const mapStateToProps = state => {
  return {
    account: state.getIn(['mutes', 'new', 'account']),
    notifications: state.getIn(['mutes', 'new', 'notifications']),
  };
};

const mapDispatchToProps = dispatch => {
  return {
    onConfirm(account, notifications) {
      dispatch(muteAccount(account.get('id'), notifications));
    },

    onClose() {
      dispatch(closeModal());
    },

    onToggleNotifications() {
      dispatch(toggleHideNotifications());
    },
  };
};

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class MuteModal extends React.PureComponent {

  static propTypes = {
    account: PropTypes.object.isRequired,
    notifications: PropTypes.bool.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    onToggleNotifications: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleClick = () => {
    this.props.onClose();
    this.props.onConfirm(this.props.account, this.props.notifications);
  }

  handleCancel = () => {
    this.props.onClose();
  }

  setRef = (c) => {
    this.button = c;
  }

  toggleNotifications = () => {
    this.props.onToggleNotifications();
  }

  render () {
    const { account, notifications } = this.props;

    return (
      <div className='modal-root__modal mute-modal'>
        <div className='mute-modal__container'>
          <p>
            <FormattedMessage
              id='confirmations.mute.message'
              defaultMessage='Are you sure you want to mute {name}?'
              values={{ name: <strong>@{account.get('acct')}</strong> }}
            />
          </p>
          <p className='mute-modal__explanation'>
            <FormattedMessage
              id='confirmations.mute.explanation'
              defaultMessage='This will hide posts from them and posts mentioning them, but it will still allow them to see your posts and follow you.'
            />
          </p>
          <div className='setting-toggle'>
            <Toggle id='mute-modal__hide-notifications-checkbox' checked={notifications} onChange={this.toggleNotifications} />
            <label className='setting-toggle__label' htmlFor='mute-modal__hide-notifications-checkbox'>
              <FormattedMessage id='mute_modal.hide_notifications' defaultMessage='Hide notifications from this user?' />
            </label>
          </div>
        </div>

        <div className='mute-modal__action-bar'>
          <Button onClick={this.handleCancel} className='mute-modal__cancel-button'>
            <FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' />
          </Button>
          <Button onClick={this.handleClick} ref={this.setRef}>
            <FormattedMessage id='confirmations.mute.confirm' defaultMessage='Mute' />
          </Button>
        </div>
      </div>
    );
  }

}
