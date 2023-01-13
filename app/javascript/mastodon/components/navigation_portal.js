import React from 'react';
import { Switch, Route, withRouter } from 'react-router-dom';
import { showTrends } from 'mastodon/initial_state';
import Trends from 'mastodon/features/getting_started/containers/trends_container';
import AccountNavigation from 'mastodon/features/account/navigation';

const DefaultNavigation = () => (
  <>
    {showTrends && (
      <>
        <div className='flex-spacer' />
        <Trends />
      </>
    )}
  </>
);

export default @withRouter
class NavigationPortal extends React.PureComponent {

  render () {
    return (
      <Switch>
        <Route path='/@:acct' exact component={AccountNavigation} />
        <Route path='/@:acct/tagged/:tagged?' exact component={AccountNavigation} />
        <Route path='/@:acct/with_replies' exact component={AccountNavigation} />
        <Route path='/@:acct/followers' exact component={AccountNavigation} />
        <Route path='/@:acct/following' exact component={AccountNavigation} />
        <Route path='/@:acct/media' exact component={AccountNavigation} />
        <Route component={DefaultNavigation} />
      </Switch>
    );
  }

}
