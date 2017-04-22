import { Link } from 'react-router';
import { FormattedMessage } from 'react-intl';

const TabsBar = React.createClass({

  render () {
    return (
      <div className='tabs-bar'>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/statuses/new'><i className='fa fa-fw fa-pencil' /><FormattedMessage id='tabs_bar.compose' defaultMessage='Compose' /></Link>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/timelines/home'><i className='fa fa-fw fa-home' /><FormattedMessage id='tabs_bar.home' defaultMessage='Home' /></Link>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/notifications'><i className='fa fa-fw fa-bell' /><FormattedMessage id='tabs_bar.notifications' defaultMessage='Notifications' /></Link>

        <Link className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public/local'><i className='fa fa-fw fa-users' /><FormattedMessage id='tabs_bar.local_timeline' defaultMessage='Local' /></Link>
        <Link className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public'><i className='fa fa-fw fa-globe' /><FormattedMessage id='tabs_bar.federated_timeline' defaultMessage='Federated' /></Link>

        <Link className='tabs-bar__link primary' activeClassName='active' style={{ flexGrow: '0', flexBasis: '30px' }} to='/getting-started'><i className='fa fa-fw fa-asterisk' /></Link>
      </div>
    );
  }

});

export default TabsBar;
