import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenu from '../../../components/dropdown_menu';
import { Link } from 'react-router';
import { defineMessages, injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';

const messages = defineMessages({
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' }
});

const outerDropdownStyle = {
  padding: '10px',
  flex: '1 1 auto'
};

const outerLinksStyle = {
  flex: '1 1 auto',
  display: 'flex',
  lineHeight: '18px'
};

const ActionBar = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func,
    onBlock: React.PropTypes.func.isRequired,
    onMention: React.PropTypes.func.isRequired,
    onReport: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me, intl } = this.props;

    let menu = [];

    menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
    menu.push(null);

    if (account.get('id') === me) {
      menu.push({ text: intl.formatMessage(messages.edit_profile), href: '/settings/profile' });
    } else if (account.getIn(['relationship', 'blocking'])) {
      menu.push({ text: intl.formatMessage(messages.unblock, { name: account.get('username') }), action: this.props.onBlock });
    } else if (account.getIn(['relationship', 'following'])) {
      menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.props.onBlock });
    } else {
      menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.props.onBlock });
    }

    if (account.get('id') !== me) {
      menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.props.onReport });
    }

    return (
      <div className='account__action-bar'>
        <div style={outerDropdownStyle}>
          <DropdownMenu items={menu} icon='bars' size={24} direction="right" />
        </div>

        <div style={outerLinksStyle}>
          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}`}>
            <span><FormattedMessage id='account.posts' defaultMessage='Posts' /></span>
            <strong><FormattedNumber value={account.get('statuses_count')} /></strong>
          </Link>

          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/following`}>
            <span><FormattedMessage id='account.follows' defaultMessage='Follows' /></span>
            <strong><FormattedNumber value={account.get('following_count')} /></strong>
          </Link>

          <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/followers`}>
            <span><FormattedMessage id='account.followers' defaultMessage='Followers' /></span>
            <strong><FormattedNumber value={account.get('followers_count')} /></strong>
          </Link>
        </div>
      </div>
    );
  }

});

export default injectIntl(ActionBar);
