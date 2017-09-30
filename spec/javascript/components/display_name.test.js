import React from 'react';
import DisplayName from '../../../app/javascript/mastodon/components/display_name';

import { expect } from 'chai';
import { render } from 'enzyme';
import { fromJS }  from 'immutable';

describe('<DisplayName />', () => {
  xit('renders display name + account name', () => {
    const account = fromJS({
      username: 'bar',
      acct: 'bar@baz',
      display_name_html: '<p>Foo</p>',
    });
    const wrapper = render(<DisplayName account={account} />);
    expect(wrapper).to.have.text('Foo @bar@baz');
  });
});
