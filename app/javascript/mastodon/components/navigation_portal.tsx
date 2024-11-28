import { Switch, Route } from 'react-router-dom';

import AccountNavigation from 'mastodon/features/account/navigation';
import Trends from 'mastodon/features/getting_started/containers/trends_container';
import { showTrends } from 'mastodon/initial_state';

const DefaultNavigation: React.FC = () => (showTrends ? <Trends /> : null);

export const NavigationPortal: React.FC = () => (
  <div className='navigation-panel__portal'>
    <Switch>
      <Route path='/@:acct' exact component={AccountNavigation} />
      <Route
        path='/@:acct/tagged/:tagged?'
        exact
        component={AccountNavigation}
      />
      <Route path='/@:acct/with_replies' exact component={AccountNavigation} />
      <Route path='/@:acct/followers' exact component={AccountNavigation} />
      <Route path='/@:acct/following' exact component={AccountNavigation} />
      <Route path='/@:acct/media' exact component={AccountNavigation} />
      <Route component={DefaultNavigation} />
    </Switch>
  </div>
);
