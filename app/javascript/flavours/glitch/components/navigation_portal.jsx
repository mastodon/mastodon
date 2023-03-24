import React from 'react';
import { Switch, Route, withRouter } from 'react-router-dom';
import { showTrends } from 'flavours/glitch/initial_state';
import Trends from 'flavours/glitch/features/getting_started/containers/trends_container';
import AccountNavigation from 'flavours/glitch/features/account/navigation';

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

export default withRouter(NavigationPortal);
