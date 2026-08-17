import { IntlProvider } from 'react-intl';

import { render, screen } from '@testing-library/react';

import { ShortNumber } from '../short_number';

function renderShortNumber(value: number) {
  return render(
    <IntlProvider locale='en'>
      <ShortNumber value={value} />
    </IntlProvider>,
  );
}

describe('ShortNumber Component', () => {
  it('does not abbreviate numbers under 1000', () => {
    renderShortNumber(999);
    expect(screen.getByText('999')).toBeDefined();
  });

  it('formats thousands correctly for 1000', () => {
    renderShortNumber(1000);
    expect(screen.getByText('1K')).toBeDefined();
  });

  it('truncates decimals for 1051', () => {
    renderShortNumber(1051);
    expect(screen.getByText('1K')).toBeDefined();
  });

  it('truncates decimals for 2999', () => {
    renderShortNumber(2999);
    expect(screen.getByText('2.9K')).toBeDefined();
  });

  it('truncates decimals for 9999', () => {
    renderShortNumber(9999);
    expect(screen.getByText('9.9K')).toBeDefined();
  });

  it('truncates decimals for 10501', () => {
    renderShortNumber(10501);
    expect(screen.getByText('10K')).toBeDefined();
  });

  it('truncates decimals for 11000', () => {
    renderShortNumber(11000);
    expect(screen.getByText('11K')).toBeDefined();
  });

  it('truncates decimals for 99999', () => {
    renderShortNumber(99999);
    expect(screen.getByText('99K')).toBeDefined();
  });

  it('truncates decimals for 100501', () => {
    renderShortNumber(100501);
    expect(screen.getByText('100K')).toBeDefined();
  });

  it('truncates decimals for 101000', () => {
    renderShortNumber(101000);
    expect(screen.getByText('101K')).toBeDefined();
  });

  it('truncates decimals for 999999', () => {
    renderShortNumber(999999);
    expect(screen.getByText('999K')).toBeDefined();
  });

  it('truncates decimals for 2999999', () => {
    renderShortNumber(2999999);
    expect(screen.getByText('2.9M')).toBeDefined();
  });

  it('truncates decimals for 9999999', () => {
    renderShortNumber(9999999);
    expect(screen.getByText('9.9M')).toBeDefined();
  });
});
