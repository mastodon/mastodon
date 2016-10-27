import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from '../../../components/avatar';
import { Link }           from 'react-router';

const outerStyle = {
  padding: '10px'
};

const displayNameStyle = {
  display: 'block',
  fontWeight: '500',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  color: '#fff'
};

const acctStyle = {
  display: 'block',
  overflow: 'hidden',
  textOverflow: 'ellipsis'
};

const itemStyle = {
  display: 'block',
  color: '#9baec8',
  overflow: 'hidden',
  textDecoration: 'none'
};

const Account = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account } = this.props;

    if (!account) {
      return <div />;
    }

    let displayName = account.get('display_name');

    if (displayName.length === 0) {
      displayName = account.get('username');
    }

    return (
      <div style={outerStyle}>
        <Link key={account.get('id')} style={itemStyle} to={`/accounts/${account.get('id')}`}>
          <div style={{ float: 'left', marginRight: '10px' }}><Avatar src={account.get('avatar')} size={36} /></div>
          <strong style={displayNameStyle}>{displayName}</strong>
          <span style={acctStyle}>{account.get('acct')}</span>
        </Link>
      </div>
    );
  }

});

export default Account;
