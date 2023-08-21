import { render, waitFor } from '@testing-library/react';

import { InlineAlert } from '../inline-alert';

it('should display the given message when mounted if show is true', () => {
  const { getByRole } = render(<InlineAlert show>Hello, world!</InlineAlert>);
  const ariaStatusRegion = getByRole('status');
  expect(ariaStatusRegion).toContainHTML('Hello, world!');
});

it('should hide the given message after the transition delay once show is set to false', async () => {
  const transitionDelay = 10;
  const { getByRole, rerender } = render(
    <InlineAlert show transitionDelay={transitionDelay}>
      Hello, world!
    </InlineAlert>,
  );
  const ariaStatusRegion = getByRole('status');
  rerender(
    <InlineAlert show={false} transitionDelay={transitionDelay}>
      Hello, world!
    </InlineAlert>,
  );

  await waitFor(
    () => {
      expect(ariaStatusRegion).not.toContainHTML('Hello, world!');
    },
    { timeout: transitionDelay + 10 },
  );
});
