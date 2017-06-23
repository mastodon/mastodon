import React from 'react';
import NavLink from 'react-router-dom/NavLink';
import { FormattedMessage } from 'react-intl';

const links = [
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/statuses/new'><i className='fa fa-fw fa-pencil' /><FormattedMessage id='tabs_bar.compose' defaultMessage='Compose' /></NavLink>,
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/timelines/home'><i className='fa fa-fw fa-home' /><FormattedMessage id='tabs_bar.home' defaultMessage='Home' /></NavLink>,
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/notifications'><i className='fa fa-fw fa-bell' /><FormattedMessage id='tabs_bar.notifications' defaultMessage='Notifications' /></NavLink>,

  <NavLink className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public/local'><i className='fa fa-fw fa-users' /><FormattedMessage id='tabs_bar.local_timeline' defaultMessage='Local' /></NavLink>,
  <NavLink className='tabs-bar__link secondary' activeClassName='active' exact to='/timelines/public'><i className='fa fa-fw fa-globe' /><FormattedMessage id='tabs_bar.federated_timeline' defaultMessage='Federated' /></NavLink>,

  <NavLink className='tabs-bar__link primary' activeClassName='active' style={{ flexGrow: '0', flexBasis: '30px' }} to='/getting-started'><i className='fa fa-fw fa-asterisk' /></NavLink>,
];

export function getPreviousLink (path) {
  const index = links.findIndex(link => link.props.to === path);

  if (index > 0) {
    return links[index - 1].props.to;
  }

  return null;
};

export function getNextLink (path) {
  const index = links.findIndex(link => link.props.to === path);

  if (index !== -1 && index < links.length - 1) {
    return links[index + 1].props.to;
  }

  return null;
};

export default class TabsBar extends React.Component {

  render () {
    return (
      <div className='tabs-bar'>
        {React.Children.toArray(links)}
      </div>
    );
  }

}
