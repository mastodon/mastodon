import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import { followAccount, unfollowAccount } from '../actions/accounts';
import { openModal } from '../actions/modal';
import { unfollowModal } from '../initial_state';
import IconButton from './icon_button';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
});

@connect()
@injectIntl
export default class FollowingControls extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map.isRequired,
  };

  handleFollowing = () => {
    const { dispatch, intl, account } = this.props;

    if (account.getIn(['relationship', 'following']) || account.getIn(['relationship', 'requested'])) {
      if (unfollowModal) {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.unfollow.message' defaultMessage='Are you sure you want to unfollow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
          confirm: intl.formatMessage(messages.unfollowConfirm),
          onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
        }));
      } else {
        dispatch(unfollowAccount(account.get('id')));
      }
    } else {
      dispatch(followAccount(account.get('id')));
    }
  }

  render () {
    const { intl, account } = this.props;
    const following = account.getIn(['relationship', 'following']);

    return (
      <IconButton
        active={following}
        icon={following ? 'user-times' : 'user-plus'}
        title={intl.formatMessage(following ? messages.unfollow : messages.follow)}
        onClick={this.handleFollowing}
      />
    );
  }

}
