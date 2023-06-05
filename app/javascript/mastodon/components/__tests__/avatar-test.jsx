import { fromJS } from 'immutable';

import renderer from 'react-test-renderer';

import { Avatar } from '../avatar';

describe('<Avatar />', () => {
  const account = fromJS({
    username: 'alice',
    acct: 'alice',
    display_name: 'Alice',
    avatar: '/animated/alice.gif',
    avatar_static: '/static/alice.jpg',
  });

  const size     = 100;

  describe('Autoplay', () => {
    it('renders a animated avatar', () => {
      const component = renderer.create(<Avatar account={account} animate size={size} />);
      const tree      = component.toJSON();

      expect(tree).toMatchSnapshot();
    });
  });

  describe('Still', () => {
    it('renders a still avatar', () => {
      const component = renderer.create(<Avatar account={account} size={size} />);
      const tree      = component.toJSON();

      expect(tree).toMatchSnapshot();
    });
  });

  // TODO add autoplay test if possible
});
