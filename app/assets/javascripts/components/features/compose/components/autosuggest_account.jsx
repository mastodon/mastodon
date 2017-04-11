import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import ImmutablePropTypes from 'react-immutable-proptypes';

const AutosuggestAccount = ({ account }) => (
  <div style={{ overflow: 'hidden' }} className='autosuggest-account'>
    <div style={{ float: 'left', marginRight: '5px' }}><Avatar src={account.get('avatar')} staticSrc={status.getIn(['account', 'avatar_static'])} size={18} /></div>
    <DisplayName account={account} />
  </div>
);

AutosuggestAccount.propTypes = {
  account: ImmutablePropTypes.map.isRequired
};

export default AutosuggestAccount;
