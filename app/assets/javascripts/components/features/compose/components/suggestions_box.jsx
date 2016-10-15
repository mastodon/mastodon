import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from '../../../components/avatar';
import DisplayName        from '../../../components/display_name';
import { Link }           from 'react-router';

const outerStyle = {
  marginBottom: '10px',
  borderTop: '1px solid #616b86'
};

const headerStyle = {
  fontSize: '14px',
  fontWeight: '500',
  display: 'block',
  padding: '10px',
  color: '#9baec8',
  background: '#454b5e',
  width: '120px',
  marginTop: '-18px'
};

const itemStyle = {
  display: 'block',
  padding: '10px',
  color: '#9baec8',
  overflow: 'hidden',
  textDecoration: 'none'
};

const displayNameStyle = {
  display: 'block',
  fontWeight: '500',
  overflow: 'hidden',
  textOverflow: 'ellipsis'
};

const acctStyle = {
  display: 'block',
  overflow: 'hidden',
  textOverflow: 'ellipsis'
};

const SuggestionsBox = React.createClass({

  propTypes: {
    accounts: ImmutablePropTypes.list.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const accounts = this.props.accounts.take(3);

    if (account.size === 0) {
      return <div />;
    }

    return (
      <div style={outerStyle}>
        <strong style={headerStyle}>Who to follow</strong>

        {accounts.map(account => {
          let displayName = account.get('display_name');

          if (displayName.length === 0) {
            displayName = account.get('username');
          }

          return (
            <Link key={account.get('id')} style={itemStyle} to={`/accounts/${account.get('id')}`}>
              <div style={{ float: 'left', marginRight: '10px' }}><Avatar src={account.get('avatar')} size={36} /></div>
              <strong style={displayNameStyle}>{displayName}</strong>
              <span style={acctStyle}>{account.get('acct')}</span>
            </Link>
          )
        })}
      </div>
    );
  }

});

export default SuggestionsBox;
