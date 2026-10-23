import { fromJS } from 'immutable';

import { mediaAttachmentFactoryAPI } from '@/testing/factories';
import { render, fireEvent, screen } from '@/testing/rendering';

import MediaGallery from '../media_gallery';

const media = fromJS([
  mediaAttachmentFactoryAPI({ type: 'image', description: 'A cat' }),
]);

const getImageLink = () => screen.getByAltText('A cat').closest('a');

describe('<MediaGallery />', () => {
  it('opens media using the given handler', () => {
    const handler = vi.fn();
    render(<MediaGallery media={media} height={100} lang='en' onOpenMedia={handler} />);

    const notPrevented = fireEvent.click(getImageLink());

    expect(handler).toHaveBeenCalledWith(media, 0, 'en');
    expect(notPrevented).toBe(false);
  });

  it('follows the link when no handler is given', () => {
    render(<MediaGallery media={media} height={100} />);

    const notPrevented = fireEvent.click(getImageLink());

    expect(notPrevented).toBe(true);
  });
});
