import { expect } from 'chai';
import { render } from 'enzyme';
import React from 'react';
import Avatar from '../../../app/javascript/mastodon/components/avatar';

describe('<Avatar />', () => {
  const src = '/path/to/image.jpg';
  const size = 100;
  const wrapper = render(<Avatar src={src} animate size={size} />);

  it('renders a div element with the given src as background', () => {
    expect(wrapper.find('div')).to.have.style('background-image', `url(${src})`);
  });

  it('renders a div element of the given size', () => {
    ['width', 'height'].map((attr) => {
      expect(wrapper.find('div')).to.have.style(attr, `${size}px`);
    });
  });
});
