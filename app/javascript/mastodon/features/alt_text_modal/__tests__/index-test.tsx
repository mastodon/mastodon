// app/javascript/mastodon/features/alt_text_modal/__tests__/index-test.tsx

import { IntlProvider } from 'react-intl';

import { List, Map } from 'immutable';

import { render } from '@testing-library/react';
import { vi } from 'vitest';

import type { RootState } from 'mastodon/store';
import { useAppSelector } from 'mastodon/store';

import { AltTextModal } from '../index';

vi.mock('mastodon/store', () => ({
  useAppSelector: vi.fn(),
  useAppDispatch: () => vi.fn(),
}));

describe('<AltTextModal />', () => {
  const mediaId = '123';
  const handleClose = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  const renderComponent = () => {
    return render(
      <IntlProvider locale='en' messages={{}}>
        <AltTextModal mediaId={mediaId} onClose={handleClose} />
      </IntlProvider>,
    );
  };

  it('renders thumbnail upload button when video has no status_id', () => {
    vi.mocked(useAppSelector).mockImplementation(
      (selector: (state: RootState) => unknown) => {
        const mockState = {
          compose: Map({
            language: 'en',
            media_attachments: List([
              Map({
                id: mediaId,
                type: 'video',
                status_id: null,
                meta: Map({ focus: Map({ x: 0, y: 0 }) }),
              }),
            ]),
          }),
          accounts: Map(),
        } as unknown as RootState;

        return selector(mockState);
      },
    );

    const { container } = renderComponent();

    const uploadInput = container.querySelector('#upload-modal__thumbnail');
    expect(uploadInput).not.toBeNull();
  });

  it('hides thumbnail upload button when video has a status_id', () => {
    vi.mocked(useAppSelector).mockImplementation(
      (selector: (state: RootState) => unknown) => {
        const mockState = {
          compose: Map({
            language: 'en',
            media_attachments: List([
              Map({
                id: mediaId,
                type: 'video',
                status_id: '456',
                meta: Map({ focus: Map({ x: 0, y: 0 }) }),
              }),
            ]),
          }),
          accounts: Map(),
        } as unknown as RootState;

        return selector(mockState);
      },
    );

    const { container } = renderComponent();

    const uploadInput = container.querySelector('#upload-modal__thumbnail');
    expect(uploadInput).toBeNull();
  });
});
