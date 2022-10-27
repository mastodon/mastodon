import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from '../initial_state';
import Avatar from './avatar';

export default class AvatarOverlay extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map.isRequired,
    animate: PropTypes.bool,
    size: PropTypes.number,
    baseSize: PropTypes.number,
    overlaySize: PropTypes.number,
  };

  static defaultProps = {
    animate: autoPlayGif,
    size: 46,
    baseSize: 36,
    overlaySize: 24,
  };

  state = {
    hovering: false,
  };

  handleMouseEnter = () => {
    if (this.props.animate) return;
    this.setState({ hovering: true });
  }

  handleMouseLeave = () => {
    if (this.props.animate) return;
    this.setState({ hovering: false });
  }

  render() {
    const { account, friend, animate, size, baseSize, overlaySize } = this.props;
    const { hovering } = this.state;

    return (
      <div className='account__avatar-overlay' style={{ width: size, height: size }}>
        <div className='account__avatar-overlay-base'><Avatar animate={hovering || animate} account={account} size={baseSize} /></div>
        <div className='account__avatar-overlay-overlay'><Avatar animate={hovering || animate} account={friend} size={overlaySize} /></div>
      </div>
    );
  }

}
