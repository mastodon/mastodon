import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenu from '../../../components/dropdown_menu';
import { Link } from 'react-router';
import { defineMessages, injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';

const messages = defineMessages({
  mention: { id: 'account.mention', defaultMessage: 'Mention' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock' },
  unblock_domain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  block: { id: 'account.block', defaultMessage: 'Block user' },
  block_domain: { id: 'account.block_domain', defaultMessage: 'Block domain' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
});

const outerStyle = {
  borderTop: '1px solid #363c4b',
  borderBottom: '1px solid #363c4b',
  lineHeight: '36px',
  overflow: 'hidden',
  flex: '0 0 auto',
  display: 'flex'
};

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
    onFollow: React.PropTypes.func.isRequired,
    onBlock: React.PropTypes.func.isRequired,
    onBlockDomain: React.PropTypes.func.isRequired,
    onMention: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me, intl } = this.props;

    let menu = [];

    menu.push({ text: intl.formatMessage(messages.mention), action: this.props.onMention });

    if (account.get('id') === me) {
      menu.push({ text: intl.formatMessage(messages.edit_profile), href: '/settings/profile' });
    } else if (account.getIn(['relationship', 'blocking_domain'])) {
      // Do not show per account block / unblock if the whole domain is filtered.
    } else if (account.getIn(['relationship', 'blocking'])) {
      menu.push({ text: intl.formatMessage(messages.unblock), action: this.props.onBlock });
    } else if (account.getIn(['relationship', 'following'])) {
      menu.push({ text: intl.formatMessage(messages.block), action: this.props.onBlock });
    } else {
      menu.push({ text: intl.formatMessage(messages.block), action: this.props.onBlock });
    }

    if (account.getIn(['relationship', 'blocking_domain'])) {
      menu.push({ text: intl.formatMessage(messages.unblock_domain), action: this.props.onBlockDomain });
    } else if (account.get('acct').indexOf('@') != -1 /* Is this account from an external instance? */) {
      menu.push({ text: intl.formatMessage(messages.block_domain), action: this.props.onBlockDomain });
    }

    return (
      <div style={outerStyle}>
        <div style={outerDropdownStyle}>
          <DropdownMenu items={menu} icon='bars' size={24} />
        </div>

        <div style={outerLinksStyle}>
          <Link to={`/accounts/${account.get('id')}`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', borderLeft: '1px solid #363c4b', padding: '10px', paddingRight: '5px' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}><FormattedMessage id='account.posts' defaultMessage='Posts' /></span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}><FormattedNumber value={account.get('statuses_count')} /></span>
          </Link>

          <Link to={`/accounts/${account.get('id')}/following`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', borderLeft: '1px solid #363c4b', padding: '10px 5px' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}><FormattedMessage id='account.follows' defaultMessage='Follows' /></span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}><FormattedNumber value={account.get('following_count')} /></span>
          </Link>

          <Link to={`/accounts/${account.get('id')}/followers`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', padding: '10px 5px', borderLeft: '1px solid #363c4b' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}><FormattedMessage id='account.followers' defaultMessage='Followers' /></span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}><FormattedNumber value={account.get('followers_count')} /></span>
          </Link>
        </div>
      </div>
    );
  }

});

export default injectIntl(ActionBar);
