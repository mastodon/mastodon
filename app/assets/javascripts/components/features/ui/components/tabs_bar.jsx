import { Link } from 'react-router';
import { FormattedMessage } from 'react-intl';
import Icon from '../../../components/icon';

const TabsBar = React.createClass({

  render () {
    return (
      <div className='tabs-bar'>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/statuses/new'><Icon icon='pencil' fixedWidth={true} /><FormattedMessage id='tabs_bar.compose' defaultMessage='Compose' /></Link>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/timelines/home'><Icon icon='home' fixedWidth={true} /><FormattedMessage id='tabs_bar.home' defaultMessage='Home' /></Link>
        <Link className='tabs-bar__link primary' activeClassName='active' to='/notifications'><Icon icon='bell' fixedWidth={true} /><FormattedMessage id='tabs_bar.notifications' defaultMessage='Notifications' /></Link>

        <Link className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public/local'><Icon icon='users' fixedWidth={true} /><FormattedMessage id='tabs_bar.local_timeline' defaultMessage='Local' /></Link>
        <Link className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public'><Icon icon='globe' fixedWidth={true} /><FormattedMessage id='tabs_bar.federated_timeline' defaultMessage='Federated' /></Link>

        <Link className='tabs-bar__link primary' activeClassName='active' style={{ flexGrow: '0', flexBasis: '30px' }} to='/getting-started'><Icon icon='bars' fixedWidth={true} /></Link>
      </div>
    );
  }

});

export default TabsBar;
