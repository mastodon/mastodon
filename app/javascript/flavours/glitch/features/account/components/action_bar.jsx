import { PureComponent } from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import { NavLink } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import { Icon } from 'flavours/glitch/components/icon';


class ActionBar extends PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  isStatusesPageActive = (match, location) => {
    if (!match) {
      return false;
    }
    return !location.pathname.match(/\/(followers|following)\/?$/);
  };

  render () {
    const { account } = this.props;

    if (account.get('suspended')) {
      return (
        <div>
          <div className='account__disclaimer'>
            <Icon id='info-circle' icon={InfoIcon} />
            <FormattedMessage
              id='account.suspended_disclaimer_full'
              defaultMessage='This user has been suspended by a moderator.'
            />
          </div>
        </div>
      );
    }

    let extraInfo = '';

    if (account.get('acct') !== account.get('username')) {
      extraInfo = (
        <div className='account__disclaimer'>
          <Icon id='info-circle' icon={InfoIcon} />
          <div>
            <FormattedMessage
              id='account.disclaimer_full'
              defaultMessage="Information below may reflect the user's profile incompletely."
            />
            {' '}
            <a target='_blank' rel='noopener' href={account.get('url')}>
              <FormattedMessage id='account.view_full_profile' defaultMessage='View full profile' />
            </a>
          </div>
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

export default ActionBar;
