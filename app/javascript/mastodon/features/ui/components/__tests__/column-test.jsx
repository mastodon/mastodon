import { IdentityContext } from 'mastodon/containers/identity_context';
import { render, fireEvent, screen } from 'mastodon/test_helpers';

import Column from '../column';

const fakeIcon = () => <span />;

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    it('runs the scroll animation if the column contains scrollable content', () => {
      const scrollToMock = jest.fn();
      const { container } = render(
        <IdentityContext.Provider value={{}}>
          <Column heading='notifications' icon='notifications' iconComponent={fakeIcon}>
            <div className='scrollable' />
          </Column>
        </IdentityContext.Provider>,
      );
      container.querySelector('.scrollable').scrollTo = scrollToMock;
      fireEvent.click(screen.getByText('notifications'));
      expect(scrollToMock).toHaveBeenCalledWith({ behavior: 'smooth', top: 0 });
    });

    it('does not try to scroll if there is no scrollable content', () => {
      render(
        <IdentityContext.Provider value={{}}>
          <Column heading='notifications' icon='notifications' iconComponent={fakeIcon} />
        </IdentityContext.Provider>
      );
      fireEvent.click(screen.getByText('notifications'));
    });
  });
});
