import Trends from 'mastodon/features/getting_started/containers/trends_container';
import { showTrends } from 'mastodon/initial_state';

export const NavigationPortal: React.FC = () => (
  <div className='navigation-panel__portal'>{showTrends && <Trends />}</div>
);
