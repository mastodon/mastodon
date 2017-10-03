import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class AvatarOverlay extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map.isRequired,
  };

  render() {
    const { account, friend } = this.props;

    const baseStyle = {
      backgroundImage: `url(${account.get('avatar_static')})`,
    };

    const overlayStyle = {
      backgroundImage: `url(${friend.get('avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-base' style={baseStyle} />
        <div className='account__avatar-overlay-overlay' style={overlayStyle} />
      </div>
    );
  }

}
