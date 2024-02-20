//  Package imports.
import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

//  Mastodon imports.
import { Avatar } from './avatar';
import { AvatarOverlay } from './avatar_overlay';
import { DisplayName } from './display_name';

export default class StatusHeader extends PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map,
    parseClick: PropTypes.func.isRequired,
  };

  //  Handles clicks on account name/image
  handleClick = (acct, e) => {
    const { parseClick } = this.props;
    parseClick(e, `/@${acct}`);
  };

  handleAccountClick = (e) => {
    const { status } = this.props;
    this.handleClick(status.getIn(['account', 'acct']), e);
  };

  //  Rendering.
  render () {
    const {
      status,
      friend,
    } = this.props;

    const account = status.get('account');

    let statusAvatar;
    if (friend === undefined || friend === null) {
      statusAvatar = <Avatar account={account} size={46} />;
    } else {
      statusAvatar = <AvatarOverlay account={account} friend={friend} />;
    }

    return (
      <a
        href={account.get('url')}
        className='status__display-name'
        target='_blank'
        onClick={this.handleAccountClick}
        rel='noopener noreferrer'
      >
        <div className='status__avatar'>
          {statusAvatar}
        </div>

        <DisplayName account={account} />
      </a>
    );
  }

}
