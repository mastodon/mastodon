import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenu       from '../../../components/dropdown_menu';
import { Link }           from 'react-router';

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
    onMention: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me } = this.props;

    let menu = [];

    menu.push({ text: 'Mention', action: this.props.onMention });

    if (account.get('id') === me) {
      menu.push({ text: 'Edit profile', href: '/settings/profile' });
    } else if (account.getIn(['relationship', 'blocking'])) {
      menu.push({ text: 'Unblock', action: this.props.onBlock });
    } else if (account.getIn(['relationship', 'following'])) {
      menu.push({ text: 'Unfollow', action: this.props.onFollow });
      menu.push({ text: 'Block', action: this.props.onBlock });
    } else {
      menu.push({ text: 'Follow', action: this.props.onFollow });
      menu.push({ text: 'Block', action: this.props.onBlock });
    }

    return (
      <div style={outerStyle}>
        <div style={outerDropdownStyle}>
          <DropdownMenu items={menu} icon='bars' size={24} />
        </div>

        <div style={outerLinksStyle}>
          <Link to={`/accounts/${account.get('id')}`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', borderLeft: '1px solid #363c4b', padding: '10px', paddingRight: '5px' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}>Posts</span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}>{account.get('statuses_count')}</span>
          </Link>

          <Link to={`/accounts/${account.get('id')}/following`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', borderLeft: '1px solid #363c4b', padding: '10px 5px' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}>Follows</span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}>{account.get('following_count')}</span>
          </Link>

          <Link to={`/accounts/${account.get('id')}/followers`} style={{ textDecoration: 'none', overflow: 'hidden', width: '80px', padding: '10px 5px', borderLeft: '1px solid #363c4b' }}>
            <span style={{ display: 'block', textTransform: 'uppercase', fontSize: '11px', color: '#616b86' }}>Followers</span>
            <span style={{ display: 'block', fontSize: '15px', fontWeight: '500', color: '#fff' }}>{account.get('followers_count')}</span>
          </Link>
        </div>
      </div>
    );
  },

});

export default ActionBar;
