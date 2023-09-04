import { PureComponent } from 'react';

import { Switch, Route, withRouter } from 'react-router-dom';

import AccountNavigation from 'flavours/glitch/features/account/navigation';
import Trends from 'flavours/glitch/features/getting_started/containers/trends_container';
import { showTrends } from 'flavours/glitch/initial_state';

const DefaultNavigation = () => (
  showTrends ? (
    <>
      <div className='flex-spacer' />
      <Trends />
    </>
  ) : null
);

class NavigationPortal extends PureComponent {

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
