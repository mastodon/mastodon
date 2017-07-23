import React from 'react';
import NavLink from 'react-router-dom/NavLink';
import { FormattedMessage } from 'react-intl';

export const links = [
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/statuses/new' data-preview-title-id='tabs_bar.compose' data-preview-icon='pencil' ><i className='fa fa-fw fa-pencil' /><FormattedMessage id='tabs_bar.compose' defaultMessage='Compose' /></NavLink>,
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/timelines/home' data-preview-title-id='column.home' data-preview-icon='home' ><i className='fa fa-fw fa-home' /><FormattedMessage id='tabs_bar.home' defaultMessage='Home' /></NavLink>,
  <NavLink className='tabs-bar__link primary' activeClassName='active' to='/notifications' data-preview-title-id='column.notifications' data-preview-icon='bell' ><i className='fa fa-fw fa-bell' /><FormattedMessage id='tabs_bar.notifications' defaultMessage='Notifications' /></NavLink>,

  <NavLink className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public/local' data-preview-title-id='column.community' data-preview-icon='users' ><i className='fa fa-fw fa-users' /><FormattedMessage id='tabs_bar.local_timeline' defaultMessage='Local' /></NavLink>,
  <NavLink className='tabs-bar__link secondary' activeClassName='active' exact to='/timelines/public' data-preview-title-id='column.public' data-preview-icon='globe' ><i className='fa fa-fw fa-globe' /><FormattedMessage id='tabs_bar.federated_timeline' defaultMessage='Federated' /></NavLink>,

  <NavLink className='tabs-bar__link primary' activeClassName='active' style={{ flexGrow: '0', flexBasis: '30px' }} to='/getting-started' data-preview-title-id='tabs_bar.federated_timeline' data-preview-icon='asterisk' ><i className='fa fa-fw fa-asterisk' /></NavLink>,
];

export function getIndex (path) {
  return links.findIndex(link => link.props.to === path);
}

export function getLink (index) {
  return links[index].props.to;
}

export default class TabsBar extends React.Component {

  render () {
    return (
      <div className='tabs-bar'>
        {React.Children.toArray(links)}
      </div>
    );
  }

}
