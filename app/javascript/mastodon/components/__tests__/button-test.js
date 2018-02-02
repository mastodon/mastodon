import { shallow } from 'enzyme';
import React from 'react';
import renderer from 'react-test-renderer';
import Button from '../button';

describe('<Button />', () => {
  it('renders a button element', () => {
    const component = renderer.create(<Button />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders the given text', () => {
    const text      = 'foo';
    const component = renderer.create(<Button text={text} />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('handles click events using the given handler', () => {
    const handler = jest.fn();
    const button  = shallow(<Button onClick={handler} />);
    button.find('button').simulate('click');

    expect(handler.mock.calls.length).toEqual(1);
  });

  it('does not handle click events if props.disabled given', () => {
    const handler = jest.fn();
    const button  = shallow(<Button onClick={handler} disabled />);
    button.find('button').simulate('click');

    expect(handler.mock.calls.length).toEqual(0);
  });

  it('renders a disabled attribute if props.disabled given', () => {
    const component = renderer.create(<Button disabled />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders the children', () => {
    const children  = <p>children</p>;
    const component = renderer.create(<Button>{children}</Button>);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders the props.text instead of children', () => {
    const text      = 'foo';
    const children  = <p>children</p>;
    const component = renderer.create(<Button text={text}>{children}</Button>);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders class="button--block" if props.block given', () => {
    const component = renderer.create(<Button block />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('adds class "button-secondary" if props.secondary given', () => {
    const component = renderer.create(<Button secondary />);
    const tree      = component.toJSON();

    expect(tree).toMatchSnapshot();
  });
});
