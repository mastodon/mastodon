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
        <Avatar account={account} size={24} />
        <DisplayName account={account} />
      </div>
    );
  }

}
