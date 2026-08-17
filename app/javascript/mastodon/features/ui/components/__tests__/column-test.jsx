import { render, fireEvent, screen } from '@/testing/rendering';

import Column from '../column';
import { FocusTargetProvider } from '@/mastodon/components/navigation_focus_target';

const fakeIcon = () => <span />;

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    it('runs the scroll animation if the column contains scrollable content', () => {
      const scrollToMock = vi.fn();
      const { container } = render(
        <FocusTargetProvider>
          <Column heading='notifications' icon='notifications' iconComponent={fakeIcon}>
            <div className='scrollable' />
          </Column>
        </FocusTargetProvider>,
      );
      container.querySelector('.scrollable').scrollTo = scrollToMock;
      fireEvent.click(screen.getByText('notifications'));
      expect(scrollToMock).toHaveBeenCalledWith({ behavior: 'smooth', top: 0 });
    });

    it('does not try to scroll if there is no scrollable content', () => {
      render(
        <FocusTargetProvider>
          <Column heading='notifications' icon='notifications' iconComponent={fakeIcon} />
        </FocusTargetProvider>
      );
      fireEvent.click(screen.getByText('notifications'));
    });
  });
});
