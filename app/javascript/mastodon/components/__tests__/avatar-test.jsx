
import { render } from '@/testing/rendering';

import { accountDefaultValues, createAccountFromServerJSON } from '@/mastodon/models/account';

import { Avatar } from '../avatar';

describe('<Avatar />', () => {
  const account = createAccountFromServerJSON({
    ...accountDefaultValues,
    username: 'alice',
    acct: 'alice',
    display_name: 'Alice',
    avatar: '/animated/alice.gif',
    avatar_static: '/static/alice.jpg',
  });

  const size     = 100;

  describe('Autoplay', () => {
    it('renders a animated avatar', () => {
      const { container } = render(<Avatar account={account} animate size={size} />);

      expect(container.firstChild).toMatchSnapshot();
    });
  });

  describe('Still', () => {
    it('renders a still avatar', () => {
      const { container } = render(<Avatar account={account} size={size} />);

      expect(container.firstChild).toMatchSnapshot();
    });
  });

  // TODO add autoplay test if possible
});
