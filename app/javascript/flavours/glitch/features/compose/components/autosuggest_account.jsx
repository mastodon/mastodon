import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { Avatar } from '../../../components/avatar';
import { DisplayName } from '../../../components/display_name';

export default class AutosuggestAccount extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.record.isRequired,
  };

  render () {
    const { account } = this.props;

    return (
      <div className='autosuggest-account' title={account.get('acct')}>
        <div className='autosuggest-account-icon'><Avatar account={account} size={18} /></div>
        <DisplayName account={account} inline />
      </div>
    );
  }

}
