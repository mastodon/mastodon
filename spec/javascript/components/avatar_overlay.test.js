import { expect } from 'chai';
import { render } from 'enzyme';
import { fromJS }  from 'immutable';
import React from 'react';
import AvatarOverlay from '../../../app/javascript/mastodon/components/avatar_overlay';

describe('<Avatar />', () => {
  const account = fromJS({
    username: 'alice',
    acct: 'alice',
    display_name: 'Alice',
    avatar: '/animated/alice.gif',
    avatar_static: '/static/alice.jpg',
  });
  const friend = fromJS({
    username: 'eve',
    acct: 'eve@blackhat.lair',
    display_name: 'Evelyn',
    avatar: '/animated/eve.gif',
    avatar_static: '/static/eve.jpg',
  });

  const overlay = render(<AvatarOverlay account={account} friend={friend} />);

  it('renders account static src as base of overlay avatar', () => {
    expect(overlay.find('.account__avatar-overlay-base'))
      .to.have.style('background-image', `url(${account.get('avatar_static')})`);
  });

  it('renders friend static src as overlay of overlay avatar', () => {
    expect(overlay.find('.account__avatar-overlay-overlay'))
      .to.have.style('background-image', `url(${friend.get('avatar_static')})`);
  });
});
