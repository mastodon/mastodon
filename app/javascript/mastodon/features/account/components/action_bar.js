import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenu from '../../../components/dropdown_menu';
import Link from 'react-router/lib/Link';
import { defineMessages, injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';

const messages = defineMessages({
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
  disclaimer: { id: 'account.disclaimer', defaultMessage: 'This user is from another instance. This number may be larger.' }
});

class ActionBar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    me: PropTypes.number.isRequired,
    onFollow: PropTypes.func,
    onBlock: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onReport: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired
  };

  render () {
    const { account, me, intl } = this.props;

    let menu = [];
    let extraInfo = '';

    menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
    menu.push(null);

    if (account.get('id') === me) {
      menu.push({ text: intl.formatMessage(messages.edit_profile), href: '/settings/profile' });
    } else {
      if (account.getIn(['relationship', 'muting'])) {
        menu.push({ text: intl.formatMessage(messages.unmute, { name: account.get('username') }), action: this.props.onMute });
      } else {
        menu.push({ text: intl.formatMessage(messages.mute, { name: account.get('username') }), action: this.props.onMute });
      }

      if (account.getIn(['relationship', 'blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblock, { name: account.get('username') }), action: this.props.onBlock });
      } else {
        menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.props.onBlock });
      }

      menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.props.onReport });
    }

    if (account.get('acct') !== account.get('username')) {
      extraInfo = <abbr title={intl.formatMessage(messages.disclaimer)}>*</abbr>;
    }

    return (
      <div className='account__action-bar'>
        <div className='account__action-bar-dropdown'>
          <DropdownMenu items={menu} icon='bars' size={24} direction="right" />
        </div>

        <div className='account__action-bar-links'>
          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}`}>
            <span><FormattedMessage id='account.posts' defaultMessage='Posts' /></span>
            <strong><FormattedNumber value={account.get('statuses_count')} /> {extraInfo}</strong>
          </Link>

          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/following`}>
            <span><FormattedMessage id='account.follows' defaultMessage='Follows' /></span>
            <strong><FormattedNumber value={account.get('following_count')} /> {extraInfo}</strong>
          </Link>

          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/followers`}>
            <span><FormattedMessage id='account.followers' defaultMessage='Followers' /></span>
            <strong><FormattedNumber value={account.get('followers_count')} /> {extraInfo}</strong>
          </Link>
        </div>
      </div>
    );
  }

}

export default injectIntl(ActionBar);
