import { fromJS } from 'immutable';

import { render } from '@/testing/rendering';

import { AvatarOverlay } from '../avatar_overlay';

describe('<AvatarOverlay', () => {
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

  it('renders a overlay avatar', () => {
    const { container } = render(<AvatarOverlay account={account} friend={friend} />);

    expect(container.firstChild).toMatchSnapshot();
  });
});
