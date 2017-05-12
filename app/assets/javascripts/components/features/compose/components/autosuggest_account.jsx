import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import ImmutablePropTypes from 'react-immutable-proptypes';

const AutosuggestAccount = ({ account }) => (
  <div className='autosuggest-account'>
    <div className='autosuggest-account-icon'><Avatar src={account.get('avatar')} staticSrc={account.get('avatar_static')} size={18} /></div>
    <DisplayName account={account} />
  </div>
);

AutosuggestAccount.propTypes = {
  account: ImmutablePropTypes.map.isRequired
};

export default AutosuggestAccount;
