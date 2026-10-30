import { fromJS } from 'immutable';

import { render, fireEvent, screen } from '@/testing/rendering';

import Option from '../../features/report/components/option';
import MediaGallery from '../media_gallery';

vi.mock('mastodon/features/video', () => ({
  formatTime: vi.fn(),
}));

describe('<MediaGallery /> visibility controls', () => {
  const media = fromJS([
    {
      id: '123',
      type: 'image',
      url: 'https://example.com/image.png',
      preview_url: 'https://example.com/preview.png',
      description: '',
      meta: { small: { aspect: 1 } },
    },
  ]);

  const renderGallery = ({
    visible,
    checked,
  }: {
    visible: boolean;
    checked: boolean;
  }): {
    reportCheckbox: HTMLInputElement;
    reportToggle: ReturnType<typeof vi.fn>;
  } => {
    const onToggle = vi.fn();

    render(
      <Option
        name='status_ids'
        value='456'
        checked={checked}
        onToggle={onToggle}
        multiple
        labelComponent={
          <MediaGallery
            media={media}
            height={200}
            visible={visible}
            onOpenMedia={vi.fn()}
          />
        }
      />,
    );

    return {
      reportCheckbox: screen.getByRole<HTMLInputElement>('checkbox'),
      reportToggle: onToggle,
    };
  };

  const expectMediaButtonPresence = () => {
    expect(screen.getByRole('button', { name: 'Hide' })).toBeTruthy();
    expect(screen.queryByRole('button', { name: /click to show/i })).toBeNull();
    expect(screen.getByAltText('')).toBeTruthy();
  };

  const expectMediaButtonHidden = () => {
    expect(screen.getByRole('button', { name: /click to show/i })).toBeTruthy();
    expect(screen.queryByRole('button', { name: 'Hide' })).toBeNull();
    expect(screen.queryByAltText('')).toBeNull();
  };

  const expectCheckboxChecked = (checked: boolean) => {
    const reportCheckbox = screen.getByRole<HTMLInputElement>('checkbox');
    expect(reportCheckbox.checked).toBe(checked);
  };

  it('keeps an unchecked report selection when showing and hiding hidden media', () => {
    const { reportCheckbox, reportToggle } = renderGallery({
      visible: false,
      checked: false,
    });

    expectMediaButtonHidden();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(
      fireEvent.click(screen.getByRole('button', { name: /click to show/i })),
    ).toBe(false);
    expectMediaButtonPresence();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(fireEvent.click(screen.getByRole('button', { name: 'Hide' }))).toBe(
      false,
    );
    expectMediaButtonHidden();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    fireEvent.click(reportCheckbox);
    expect(reportToggle).toHaveBeenCalledExactlyOnceWith('456', true);
  });

  it('keeps a checked report selection when showing and hiding hidden media', () => {
    const { reportCheckbox, reportToggle } = renderGallery({
      visible: false,
      checked: true,
    });

    expectMediaButtonHidden();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(
      fireEvent.click(screen.getByRole('button', { name: /click to show/i })),
    ).toBe(false);
    expectMediaButtonPresence();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(fireEvent.click(screen.getByRole('button', { name: 'Hide' }))).toBe(
      false,
    );
    expectMediaButtonHidden();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    fireEvent.click(reportCheckbox);
    expect(reportToggle).toHaveBeenCalledExactlyOnceWith('456', false);
  });

  it('keeps an unchecked report selection when hiding and showing visible media', () => {
    const { reportCheckbox, reportToggle } = renderGallery({
      visible: true,
      checked: false,
    });

    expectMediaButtonPresence();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(fireEvent.click(screen.getByRole('button', { name: 'Hide' }))).toBe(
      false,
    );
    expectMediaButtonHidden();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(
      fireEvent.click(screen.getByRole('button', { name: /click to show/i })),
    ).toBe(false);
    expectMediaButtonPresence();
    expectCheckboxChecked(false);
    expect(reportToggle).not.toHaveBeenCalled();

    fireEvent.click(reportCheckbox);
    expect(reportToggle).toHaveBeenCalledExactlyOnceWith('456', true);
  });

  it('keeps a checked report selection when hiding and showing visible media', () => {
    const { reportCheckbox, reportToggle } = renderGallery({
      visible: true,
      checked: true,
    });

    expectMediaButtonPresence();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(fireEvent.click(screen.getByRole('button', { name: 'Hide' }))).toBe(
      false,
    );
    expectMediaButtonHidden();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    // Prevent the enclosing label from toggling the report selection.
    expect(
      fireEvent.click(screen.getByRole('button', { name: /click to show/i })),
    ).toBe(false);
    expectMediaButtonPresence();
    expectCheckboxChecked(true);
    expect(reportToggle).not.toHaveBeenCalled();

    fireEvent.click(reportCheckbox);
    expect(reportToggle).toHaveBeenCalledExactlyOnceWith('456', false);
  });
});
