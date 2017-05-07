import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import IconButton from './icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' }
});

class Account extends ImmutablePureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleFollow = this.handleFollow.bind(this);
    this.handleBlock = this.handleBlock.bind(this);
    this.handleMute = this.handleMute.bind(this);
  }

  handleFollow () {
    this.props.onFollow(this.props.account);
  }

  handleBlock () {
    this.props.onBlock(this.props.account);
  }

  handleMute () {
    this.props.onMute(this.props.account);
  }

  render () {
    const { account, me, intl } = this.props;

    if (!account) {
      return <div />;
    }

    let buttons;

    if (account.get('id') !== me && account.get('relationship', null) !== null) {
      const following = account.getIn(['relationship', 'following']);
      const requested = account.getIn(['relationship', 'requested']);
      const blocking  = account.getIn(['relationship', 'blocking']);
      const muting  = account.getIn(['relationship', 'muting']);

      if (requested) {
        buttons = <IconButton disabled={true} icon='hourglass' title={intl.formatMessage(messages.requested)} />
      } else if (blocking) {
        buttons = <IconButton active={true} icon='unlock-alt' title={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.handleBlock} />;
      } else if (muting) {
        buttons = <IconButton active={true} icon='volume-up' title={intl.formatMessage(messages.unmute, { name: account.get('username') })} onClick={this.handleMute} />;
      } else {
        buttons = <IconButton icon={following ? 'user-times' : 'user-plus'} title={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollow} active={following} />;
      }
    }

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar src={account.get('avatar')} staticSrc={account.get('avatar_static')} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            {buttons}
          </div>
        </div>
      </div>
    );
  }

}

Account.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
  me: PropTypes.number.isRequired,
  onFollow: PropTypes.func.isRequired,
  onBlock: PropTypes.func.isRequired,
  onMute: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
}

export default injectIntl(Account);
