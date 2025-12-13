import { render, fireEvent, screen } from '@/testing/rendering';

import Column from '../column';

const fakeIcon = () => <span />;

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    it('runs the scroll animation if the column contains scrollable content', () => {
      const scrollToMock = vi.fn();
      const { container } = render(
        <Column heading='notifications' icon='notifications' iconComponent={fakeIcon}>
          <div className='scrollable' />
        </Column>,
      );
      container.querySelector('.scrollable').scrollTo = scrollToMock;
      fireEvent.click(screen.getByText('notifications'));
      expect(scrollToMock).toHaveBeenCalledWith({ behavior: 'smooth', top: 0 });
    });

    it('does not try to scroll if there is no scrollable content', () => {
      render(<Column heading='notifications' icon='notifications' iconComponent={fakeIcon} />);
      fireEvent.click(screen.getByText('notifications'));
    });
  });
});
