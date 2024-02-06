import renderer from 'react-test-renderer';

import AutosuggestEmoji from '../autosuggest_emoji';

describe('<AutosuggestEmoji />', () => {
  it('renders native emoji', () => {
    const emoji = {
      native: '💙',
      colons: ':foobar:',
    };
    const component = renderer.create(<AutosuggestEmoji emoji={emoji} />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders emoji with custom url', () => {
    const emoji = {
      custom: true,
      imageUrl: 'http://example.com/emoji.png',
      native: 'foobar',
      colons: ':foobar:',
    };
    const component = renderer.create(<AutosuggestEmoji emoji={emoji} />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });
});
