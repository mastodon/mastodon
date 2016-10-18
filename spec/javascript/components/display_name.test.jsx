import { expect } from 'chai';
import { render } from 'enzyme';
import Immutable  from 'immutable';

import DisplayName from '../../../app/assets/javascripts/components/components/display_name'

describe('<DisplayName />', () => {
  const account = Immutable.fromJS({
    username: 'bar',
    acct: 'bar@baz',
    display_name: 'Foo'
  });

  const wrapper = render(<DisplayName account={account} />);

  it('renders display name', () => {
    expect(wrapper.text()).to.match(/Foo @bar@baz/);
  });
});
