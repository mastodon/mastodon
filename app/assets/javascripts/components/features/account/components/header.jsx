import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Button             from '../../../components/button';

const Header = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    onFollow: React.PropTypes.func.isRequired,
    onUnfollow: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account } = this.props;

    return (
      <div style={{ flex: '0 0 auto', background: '#2f3441', textAlign: 'center', backgroundImage: `url(${account.get('header')})`, backgroundSize: 'cover' }}>
        <div style={{ background: 'rgba(47, 52, 65, 0.6)', padding: '30px 10px' }}>
          <div style={{ width: '90px', margin: '0 auto', marginBottom: '15px', borderRadius: '90px', overflow: 'hidden' }} className='transparent-background'>
            <img src={account.get('avatar')} alt='' style={{ display: 'block', width: '90px', height: '90px', borderRadius: '90px' }} />
          </div>

          <span style={{ color: '#fff', fontSize: '20px', lineHeight: '27px', fontWeight: '500', display: 'block' }}>{account.get('display_name')}</span>
          <span style={{ fontSize: '14px', fontWeight: '400', display: 'block', color: '#2b90d9', marginBottom: '15px' }}>@{account.get('acct')}</span>
          <p style={{ color: '#616b86', fontSize: '14px' }}>{account.get('note')}</p>
        </div>
      </div>
    );
  }

});

export default Header;
