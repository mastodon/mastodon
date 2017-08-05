import { expect } from 'chai';
import { render } from 'enzyme';
import { fromJS }  from 'immutable';
import React from 'react';
import Avatar from '../../../app/javascript/mastodon/components/avatar';

describe('<Avatar />', () => {
  const account = fromJS({
    username: 'alice',
    acct: 'alice',
    display_name: 'Alice',
    avatar: '/animated/alice.gif',
    avatar_static: '/static/alice.jpg',
  });
  const size = 100;
  const animated = render(<Avatar account={account} animate size={size} />);
  const still = render(<Avatar account={account} size={size} />);

  // Autoplay
  it('renders a div element with the given src as background', () => {
    expect(animated.find('div')).to.have.style('background-image', `url(${account.get('avatar')})`);
  });

  it('renders a div element of the given size', () => {
    ['width', 'height'].map((attr) => {
      expect(animated.find('div')).to.have.style(attr, `${size}px`);
    });
  });

  // Still
  it('renders a div element with the given static src as background if not autoplay', () => {
    expect(still.find('div')).to.have.style('background-image', `url(${account.get('avatar_static')})`);
  });

  it('renders a div element of the given size if not autoplay', () => {
    ['width', 'height'].map((attr) => {
      expect(still.find('div')).to.have.style(attr, `${size}px`);
    });
  });

  // TODO add autoplay test if possible
});
