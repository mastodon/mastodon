import { fromJS } from 'immutable';

import { render, fireEvent, screen } from '@/testing/rendering';

import Option from '../../features/report/components/option';
import MediaGallery from '../media_gallery';

vi.mock('mastodon/features/video', () => ({
  formatTime: vi.fn(),
}));

describe('<MediaGallery /> visibility controls', () => {
  const media = fromJS([{
    id: '123',
    type: 'image',
    url: 'https://example.com/image.png',
    preview_url: 'https://example.com/preview.png',
    description: '',
    meta: { small: { aspect: 1 } },
  }]);

  describe.each([false, true])('when initial media visibility is %s', (visible) => {
    it.each([false, true])('preserves report selection when checked=%s while showing and hiding media', (checked) => {
      const onToggle = vi.fn();

      render(
        <Option
          name='status_ids'
          value='456'
          checked={checked}
          onToggle={onToggle}
          multiple
          labelComponent={
            <MediaGallery media={media} height={200} visible={visible} onOpenMedia={vi.fn()} />
          }
        />,
      );

      const checkbox = screen.getByRole('checkbox');
      const showButtonName = /click to show/i;

      const expectVisibility = (isVisible) => {
        if (isVisible) {
          expect(screen.getByRole('button', { name: 'Hide' })).toBeTruthy();
          expect(screen.queryByRole('button', { name: showButtonName })).toBeNull();
          expect(screen.getByAltText('')).toBeTruthy();
        } else {
          expect(screen.getByRole('button', { name: showButtonName })).toBeTruthy();
          expect(screen.queryByRole('button', { name: 'Hide' })).toBeNull();
          expect(screen.queryByAltText('')).toBeNull();
        }

        expect(checkbox.checked).toBe(checked);
        expect(onToggle).not.toHaveBeenCalled();
      };

      expectVisibility(visible);

      // Toggle twice to exercise both show and hide in either starting state.
      for (const currentVisibility of [visible, !visible]) {
        const button = screen.getByRole('button', {
          name: currentVisibility ? 'Hide' : showButtonName,
        });

        // A canceled default action prevents activation of the enclosing label.
        expect(fireEvent.click(button)).toBe(false);
        expectVisibility(!currentVisibility);
      }

      // Clicking the checkbox itself must still toggle report selection.
      fireEvent.click(checkbox);
      expect(onToggle).toHaveBeenCalledExactlyOnceWith('456', !checked);
    });
  });
});
