import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import IconButton from '../../../components/icon_button';
import DisplayName from '../../../components/display_name';
import Permalink from '../../../components/permalink';
import { FormattedMessage } from 'react-intl';
import { Link } from 'react-router';
import ImmutablePureComponent from 'react-immutable-pure-component';

class NavigationBar extends ImmutablePureComponent {

  render () {
    return (
      <div className='navigation-bar'>
        <Permalink href={this.props.account.get('url')} to={`/accounts/${this.props.account.get('id')}`}>
          <Avatar src={this.props.account.get('avatar')} animate size={40} />
        </Permalink>

        <div className='navigation-bar__profile'>
          <Permalink href={this.props.account.get('url')} to={`/accounts/${this.props.account.get('id')}`}>
            <strong className='navigation-bar__profile-account'>@{this.props.account.get('acct')}</strong>
          </Permalink>

          <a href='/settings/profile' className='navigation-bar__profile-edit'><FormattedMessage id='navigation_bar.edit_profile' defaultMessage='Edit profile' /></a>
        </div>
      </div>
    );
  }

}

NavigationBar.propTypes = {
  account: ImmutablePropTypes.map.isRequired
};

export default NavigationBar;
