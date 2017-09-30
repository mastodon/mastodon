import React from 'react';
import Button from '../../../app/javascript/mastodon/components/button';

import { expect } from 'chai';
import { shallow } from 'enzyme';
import sinon from 'sinon';

describe('<Button />', () => {
  xit('renders a button element', () => {
    const wrapper = shallow(<Button />);
    expect(wrapper).to.match('button');
  });

  xit('renders the given text', () => {
    const text = 'foo';
    const wrapper = shallow(<Button text={text} />);
    expect(wrapper.find('button')).to.have.text(text);
  });

  it('handles click events using the given handler', () => {
    const handler = sinon.spy();
    const wrapper = shallow(<Button onClick={handler} />);
    wrapper.find('button').simulate('click');
    expect(handler.calledOnce).to.equal(true);
  });

  it('does not handle click events if props.disabled given', () => {
    const handler = sinon.spy();
    const wrapper = shallow(<Button onClick={handler} disabled />);
    wrapper.find('button').simulate('click');
    expect(handler.called).to.equal(false);
  });

  xit('renders a disabled attribute if props.disabled given', () => {
    const wrapper = shallow(<Button disabled />);
    expect(wrapper.find('button')).to.be.disabled();
  });

  xit('renders the children', () => {
    const children = <p>children</p>;
    const wrapper = shallow(<Button>{children}</Button>);
    expect(wrapper.find('button')).to.contain(children);
  });

  xit('renders the props.text instead of children', () => {
    const text = 'foo';
    const children = <p>children</p>;
    const wrapper = shallow(<Button text={text}>{children}</Button>);
    expect(wrapper.find('button')).to.have.text(text);
    expect(wrapper.find('button')).to.not.contain(children);
  });

  xit('renders style="display: block; width: 100%;" if props.block given', () => {
    const wrapper = shallow(<Button block />);
    expect(wrapper.find('button')).to.have.className('button--block');
  });

  xit('renders style="display: inline-block; width: auto;" by default', () => {
    const wrapper = shallow(<Button />);
    expect(wrapper.find('button')).to.not.have.className('button--block');
  });

  xit('adds class "button-secondary" if props.secondary given', () => {
    const wrapper = shallow(<Button secondary />);
    expect(wrapper.find('button')).to.have.className('button-secondary');
  });

  xit('does not add class "button-secondary" by default', () => {
    const wrapper = shallow(<Button />);
    expect(wrapper.find('button')).to.not.have.className('button-secondary');
  });
});
