import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from '../../../components/avatar';
import DisplayName        from '../../../components/display_name';
import { Link }           from 'react-router';
import IconButton         from '../../../components/icon_button';

const outerStyle = {
  padding: '10px',
  borderBottom: '1px solid #363c4b'
};

const itemStyle = {
  flex: '1 1 auto',
  display: 'block',
  color: '#9baec8',
  overflow: 'hidden',
  textDecoration: 'none',
  fontSize: '14px'
};

const noteStyle = {
  paddingTop: '5px',
  fontSize: '12px',
  color: '#616b86'
};

const buttonsStyle = {
  padding: '10px'
};

const Account = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func.isRequired,
    withNote: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  handleFollow () {
    this.props.onFollow(this.props.account);
  },

  render () {
    const { account, me } = this.props;

    if (!account) {
      return <div />;
    }

    let note, buttons;

    if (account.get('note').length > 0) {
      note = <div style={noteStyle}>{account.get('note')}</div>;
    }

    if (account.get('id') !== me) {
      buttons = (
        <div style={buttonsStyle}>
          <IconButton icon='user-plus' title='Follow' onClick={this.handleFollow} active={account.getIn(['relationship', 'following'])} />
        </div>
      );
    }

    return (
      <div style={outerStyle}>
        <div style={{ display: 'flex' }}>
          <Link key={account.get('id')} style={itemStyle} className='account__display-name' to={`/accounts/${account.get('id')}`}>
            <div style={{ float: 'left', marginRight: '10px' }}><Avatar src={account.get('avatar')} size={36} /></div>
            <DisplayName account={account} />
          </Link>

          {buttons}
        </div>

        {note}
      </div>
    );
  }

});

export default Account;
