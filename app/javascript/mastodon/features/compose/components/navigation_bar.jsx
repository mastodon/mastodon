import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import Permalink from '../../../components/permalink';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { Avatar } from '../../../components/avatar';

import ActionBar from './action_bar';

export default class NavigationBar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onLogout: PropTypes.func.isRequired,
    onClose: PropTypes.func,
  };

  render () {
    const username = this.props.account.get('acct')
    return (
      <div className='navigation-bar'>
        <Permalink href={this.props.account.get('url')} to={`/@${username}`}>
          <span style={{ display: 'none' }}>{username}</span>
          <Avatar account={this.props.account} size={46} />
        </Permalink>

        <div className='navigation-bar__profile'>
          <span>
            <Permalink href={this.props.account.get('url')} to={`/@${username}`}>
              <strong className='navigation-bar__profile-account'>@{username}</strong>
            </Permalink>
          </span>

          <span>
            <a href='/settings/profile' className='navigation-bar__profile-edit'><FormattedMessage id='navigation_bar.edit_profile' defaultMessage='Edit profile' /></a>
          </span>
        </div>

        <div className='navigation-bar__actions'>
          <ActionBar account={this.props.account} onLogout={this.props.onLogout} />
        </div>
      </div>
    );
  }

}
