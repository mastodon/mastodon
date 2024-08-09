import renderer from 'react-test-renderer';

import { render, screen } from 'mastodon/test_helpers';

import ButtonScrollList from '../button_scroll_list';

jest.mock('mastodon/components/icon', () => {
  return {
    Icon: () => <div>MockIcon</div>,
  };
});

describe('<ButtonScrollList />', () => {
  it('renders an empty button scroll list element', () => {
    const children = [];
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const tree = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('renders the children', () => {
    const children = Array.from({ length: 5 }, (_, i) => (
      <div key={i} ref={jest.fn()} />
    ));
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const tree = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('scrolls left', () => {
    const children = Array.from({ length: 5 }, (_, i) => (
      <div key={i} ref={jest.fn()} />
    ));
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const instance = component.getInstance();
    instance.scrollLeft();
  });

  it('scrolls right', () => {
    const children = Array.from({ length: 5 }, (_, i) => (
      <div key={i} ref={jest.fn()} />
    ));
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const instance = component.getInstance();
    instance.scrollRight();
  });

  it('scrolls left and right correctly', () => {
    const children = Array.from({ length: 10 }, (_, i) => (
      <div key={i}>{i}</div>
    ));
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );

    setTimeout(() => {
      let instance = component.getInstance();
      instance.scrollRight();
      expect(instance.slide).toBe(1);
    }, 1000);

    setTimeout(() => {
      let instance = component.getInstance();
      instance.scrollLeft();
      expect(instance.slide).toBe(0);
    }, 2000);
  });

  it('handles a single child correctly', () => {
    const children = [<div key={0} ref={jest.fn()} />];
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const tree = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('handles a large number of children correctly', () => {
    const children = Array.from({ length: 50 }, (_, i) => (
      <div key={i} ref={jest.fn()} />
    ));
    const component = renderer.create(
      <ButtonScrollList>{children}</ButtonScrollList>,
    );
    const tree = component.toJSON();

    expect(tree).toMatchSnapshot();
  });

  it('checks if scroll buttons are accessible', () => {
    const children = Array.from({ length: 5 }, (_, i) => (
      <div key={i} ref={jest.fn()} />
    ));
    render(<ButtonScrollList>{children}</ButtonScrollList>);

    const leftButton = screen.getByRole('button', { name: /scroll left/i });
    const rightButton = screen.getByRole('button', { name: /scroll right/i });

    expect(leftButton).toBeTruthy();
    expect(rightButton).toBeTruthy();

    leftButton.focus();
    expect(document.activeElement).toBe(leftButton);

    rightButton.focus();
    expect(document.activeElement).toBe(rightButton);
  });
});
