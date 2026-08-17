import { List as ImmutableList } from 'immutable';

import { render, screen } from '@/testing/rendering';
import { AccountCategoryFactory } from 'mastodon/models/account_categories';

import { CategoryBadges } from '../category_badges';

describe('<CategoryBadges />', () => {
  const createCategory = (name: string, mandatory: boolean) =>
    AccountCategoryFactory({
      id: name.toLowerCase(),
      name,
      mandatory_for_readers: mandatory,
    });

  it('renders nothing when categories is null', () => {
    const { container } = render(<CategoryBadges categories={null} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders nothing when categories is empty', () => {
    const categories = ImmutableList([]);
    const { container } = render(<CategoryBadges categories={categories} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders category badges', () => {
    const categories = ImmutableList([
      createCategory('News', false),
      createCategory('Opinion', true),
    ]);

    render(<CategoryBadges categories={categories} />);

    expect(screen.getByText('News')).toBeTruthy();
    expect(screen.getByText('Opinion')).toBeTruthy();
  });

  it('applies red border for mandatory categories', () => {
    const categories = ImmutableList([createCategory('Opinion', true)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('Opinion');
    expect(badge.style.borderColor).toBe('rgb(221, 51, 51)');
  });

  it('applies grey border for regular categories', () => {
    const categories = ImmutableList([createCategory('News', false)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('News');
    expect(badge.style.borderColor).toBe('rgb(108, 117, 125)');
  });

  it('includes title attribute for accessibility', () => {
    const categories = ImmutableList([createCategory('Opinion', true)]);

    render(<CategoryBadges categories={categories} />);

    const badge = screen.getByText('Opinion');
    expect(badge.getAttribute('title')).toBe('Opinion (featured)');
  });

  it('applies custom className', () => {
    const categories = ImmutableList([createCategory('News', false)]);

    const { container } = render(
      <CategoryBadges categories={categories} className='custom-class' />,
    );

    expect(container.firstChild).toBeInstanceOf(HTMLElement);
    const root = container.firstChild as HTMLElement;
    expect(root.classList.contains('category-badges')).toBe(true);
    expect(root.classList.contains('custom-class')).toBe(true);
  });
});
