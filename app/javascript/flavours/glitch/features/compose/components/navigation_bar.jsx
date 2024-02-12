import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { Permalink } from 'flavours/glitch/components/permalink';
import { profileLink } from 'flavours/glitch/utils/backend_links';

import { Avatar } from '../../../components/avatar';

import ActionBar from './action_bar';

export default class NavigationBar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.record.isRequired,
    onLogout: PropTypes.func.isRequired,
    onClose: PropTypes.func,
  };

  render () {
    const username = this.props.account.get('acct');
    return (
      <div className='navigation-bar'>
        <Permalink className='avatar' href={this.props.account.get('url')} to={`/@${username}`}>
          <span style={{ display: 'none' }}>{username}</span>
          <Avatar account={this.props.account} size={46} />
        </Permalink>

        <div className='navigation-bar__profile'>
          <span>
            <Permalink className='acct' href={this.props.account.get('url')} to={`/@${username}`}>
              <strong className='navigation-bar__profile-account'>@{username}</strong>
            </Permalink>
          </span>

          { profileLink !== undefined && (
            <a
              href={profileLink}
              className='navigation-bar__profile-edit'
            ><FormattedMessage id='navigation_bar.edit_profile' defaultMessage='Edit profile' /></a>
          )}
        </div>

        <div className='navigation-bar__actions'>
          <ActionBar account={this.props.account} onLogout={this.props.onLogout} />
        </div>
      </div>
    );
  }

}
