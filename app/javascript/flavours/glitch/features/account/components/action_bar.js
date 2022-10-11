import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { NavLink } from 'react-router-dom';
import { injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';
import { me, isStaff } from 'flavours/glitch/initial_state';
import { profileLink, accountAdminLink } from 'flavours/glitch/utils/backend_links';
import Icon from 'flavours/glitch/components/icon';

export default @injectIntl
class ActionBar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
  };

  isStatusesPageActive = (match, location) => {
    if (!match) {
      return false;
    }
    return !location.pathname.match(/\/(followers|following)\/?$/);
  }

  render () {
    const { account, intl } = this.props;

    if (account.get('suspended')) {
      return (
        <div>
          <div className='account__disclaimer'>
            <Icon id='info-circle' fixedWidth /> <FormattedMessage
              id='account.suspended_disclaimer_full'
              defaultMessage="This user has been suspended by a moderator."
            />
          </div>
        </div>
      );
    }

    let extraInfo = '';

    if (account.get('acct') !== account.get('username')) {
      extraInfo = (
        <div className='account__disclaimer'>
          <Icon id='info-circle' fixedWidth /> <FormattedMessage
            id='account.disclaimer_full'
            defaultMessage="Information below may reflect the user's profile incompletely."
          />
          {' '}
          <a target='_blank' rel='noopener' href={account.get('url')}>
            <FormattedMessage id='account.view_full_profile' defaultMessage='View full profile' />
          </a>
        </div>
      );
    }

    return (
      <div>
        {extraInfo}

        <div className='account__action-bar'>
          <div className='account__action-bar-links'>
            <NavLink isActive={this.isStatusesPageActive} activeClassName='active' className='account__action-bar__tab' to={`/@${account.get('acct')}`}>
              <FormattedMessage id='account.posts' defaultMessage='Posts' />
              <strong><FormattedNumber value={account.get('statuses_count')} /></strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/@${account.get('acct')}/following`}>
              <FormattedMessage id='account.follows' defaultMessage='Follows' />
              <strong><FormattedNumber value={account.get('following_count')} /></strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/@${account.get('acct')}/followers`}>
              <FormattedMessage id='account.followers' defaultMessage='Followers' />
              <strong>{ account.get('followers_count') < 0 ? '-' : <FormattedNumber value={account.get('followers_count')} /> }</strong>
            </NavLink>
          </div>
        </div>
      </div>
    );
  }

}
