import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { autoPlayGif } from 'flavours/glitch/initial_state';

export default class AvatarOverlay extends PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map.isRequired,
    animate: PropTypes.bool,
  };

  static defaultProps = {
    animate: autoPlayGif,
  };

  render() {
    const { account, friend, animate } = this.props;

    const baseStyle = {
      backgroundImage: `url(${account.get(animate ? 'avatar' : 'avatar_static')})`,
    };

    const overlayStyle = {
      backgroundImage: `url(${friend.get(animate ? 'avatar' : 'avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-base' style={baseStyle} data-avatar-of={`@${account.get('acct')}`} />
        <div className='account__avatar-overlay-overlay' style={overlayStyle} data-avatar-of={`@${friend.get('acct')}`} />
      </div>
    );
  }

}
