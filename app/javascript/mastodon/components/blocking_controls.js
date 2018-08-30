import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import { blockAccount, unblockAccount } from '../actions/accounts';
import IconButton from './icon_button';

const messages = defineMessages({
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
});

@connect()
@injectIntl
export default class BlockingControls extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map.isRequired,
  };

  handleBlocking = () => {
    const { dispatch, account } = this.props;

    if (account.getIn(['relationship', 'blocking'])) {
      dispatch(unblockAccount(account.get('id')));
    } else {
      dispatch(blockAccount(account.get('id')));
    }
  }

  render () {
    const { intl, account } = this.props;
    const blocking = account.getIn(['relationship', 'blocking']);

    return (
      <IconButton
        active
        icon={blocking ? 'unlock-alt' : 'lock'}
        title={intl.formatMessage(blocking ? messages.unblock : messages.block, { name: account.get('username') })}
        onClick={this.handleBlocking}
      />
    );
  }

}
