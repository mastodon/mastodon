import { expect } from 'chai';
import { render } from 'enzyme';
import { fromJS }  from 'immutable';
import React from 'react';
import DisplayName from '../../../app/javascript/mastodon/components/display_name';

describe('<DisplayName />', () => {
  it('renders display name + account name', () => {
    const account = fromJS({
      username: 'bar',
      acct: 'bar@baz',
      display_name: 'Foo',
    });
    const wrapper = render(<DisplayName account={account} />);
    expect(wrapper).to.have.text('Foo @bar@baz');
  });

  it('renders the username + account name if display name is empty', () => {
    const account = fromJS({
      username: 'bar',
      acct: 'bar@baz',
      display_name: '',
    });
    const wrapper = render(<DisplayName account={account} />);
    expect(wrapper).to.have.text('bar @bar@baz');
  });
});
