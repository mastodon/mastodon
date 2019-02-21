//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Mastodon imports.
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import DisplayName from './display_name';

export default class StatusHeader extends React.PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map,
    parseClick: PropTypes.func.isRequired,
  };

  //  Handles clicks on account name/image
  handleAccountClick = (e) => {
    const { status, parseClick } = this.props;
    parseClick(e, `/accounts/${status.getIn(['account', 'id'])}`);
  }

  //  Rendering.
  render () {
    const {
      status,
      friend,
    } = this.props;

    const account = status.get('account');

    return (
      <div className='status__info__account' >
        <a
          href={account.get('url')}
          target='_blank'
          className='status__avatar'
          onClick={this.handleAccountClick}
        >
          {
            friend ? (
              <AvatarOverlay account={account} friend={friend} />
            ) : (
              <Avatar account={account} size={48} />
            )
          }
        </a>
        <a
          href={account.get('url')}
          target='_blank'
          className='status__display-name'
          onClick={this.handleAccountClick}
        >
          <DisplayName account={account} />
        </a>
      </div>
    );
  }

}
