import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { Avatar } from '../../../components/avatar';
import { IconButton } from '../../../components/icon_button';

import ActionBar from './action_bar';

export default class NavigationBar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onLogout: PropTypes.func.isRequired,
    onClose: PropTypes.func,
  };

  render () {
    return (
      <div className='navigation-bar'>
        <Link to={`/@${this.props.account.get('acct')}`}>
          <span style={{ display: 'none' }}>{this.props.account.get('acct')}</span>
          <Avatar account={this.props.account} size={46} />
        </Link>

        <div className='navigation-bar__profile'>
          <Link to={`/@${this.props.account.get('acct')}`}>
            <strong className='navigation-bar__profile-account'>@{this.props.account.get('acct')}</strong>
          </Link>

          <a href='/settings/profile' className='navigation-bar__profile-edit'><FormattedMessage id='navigation_bar.edit_profile' defaultMessage='Edit profile' /></a>
        </div>

        <div className='navigation-bar__actions'>
          <IconButton className='close' title='' icon='close' onClick={this.props.onClose} />
          <ActionBar account={this.props.account} onLogout={this.props.onLogout} />
        </div>
      </div>
    );
  }

}
