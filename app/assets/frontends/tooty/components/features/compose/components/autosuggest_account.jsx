import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';

const AutosuggestAccount = ({ account }) => (
  <div style={{ overflow: 'hidden' }}>
    <div style={{ float: 'left', marginRight: '5px' }}><Avatar src={account.get('avatar')} size={18} /></div>
    <DisplayName account={account} />
  </div>
);

export default AutosuggestAccount;
