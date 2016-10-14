import { expect } from 'chai';
import { render } from 'enzyme';

import Avatar from '../../../app/assets/javascripts/components/components/avatar'

describe('<Avatar />', () => {
  const src = '/path/to/image.jpg';
  const size = 100;
  const wrapper = render(<Avatar src={src} size={size} />);

  it('renders an img element with the given src', () => {
    expect(wrapper.find('img')).to.have.attr('src', `${src}`);
  });

  it('renders an img element of the given size', () => {
    ['width', 'height'].map((attr) => {
      expect(wrapper.find('img')).to.have.attr(attr, `${size}`);
    });
  });

  it('renders a div element of the given size', () => {
    ['width', 'height'].map((attr) => {
      expect(wrapper.find('div')).to.have.style(attr, `${size}px`);
    });
  });
});
