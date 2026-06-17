import { render, fireEvent, screen } from '@/testing/rendering';

import { Button } from '../button';

describe('<Button />', () => {
  it('renders a button element', () => {
    const { container } = render(<Button />);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('renders the given text', () => {
    const text      = 'foo';
    const { container } = render(<Button text={text} />);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('handles click events using the given handler', () => {
    const handler = vi.fn();
    render(<Button onClick={handler}>button</Button>);
    fireEvent.click(screen.getByText('button'));

    expect(handler.mock.calls.length).toEqual(1);
  });

  it('does not handle click events if props.disabled given', () => {
    const handler = vi.fn();
    render(<Button onClick={handler} disabled>button</Button>);
    fireEvent.click(screen.getByText('button'));

    expect(handler.mock.calls.length).toEqual(0);
  });

  it('renders a disabled attribute if props.disabled given', () => {
    const { container } = render(<Button disabled />);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('renders the children', () => {
    const children  = <p>children</p>;
    const { container } = render(<Button>{children}</Button>);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('renders the props.text instead of children', () => {
    const text      = 'foo';
    const children  = <p>children</p>;
    const { container } = render(<Button text={text}>{children}</Button>);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('renders class="button--block" if props.block given', () => {
    const { container } = render(<Button block />);

    expect(container.firstChild).toMatchSnapshot();
  });

  it('adds class "button-secondary" if props.secondary given', () => {
    const { container } = render(<Button secondary />);

    expect(container.firstChild).toMatchSnapshot();
  });
});
