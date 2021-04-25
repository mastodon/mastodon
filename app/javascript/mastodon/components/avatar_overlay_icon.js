import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from '../initial_state';

const icons = {
  public: 'globe',
  unlisted: 'unlock',
  private: 'lock',
  direct: 'envelope',
};

export default class AvatarOverlayIcon extends React.PureComponent {
  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    visibility: PropTypes.string.isRequired,
    animate: PropTypes.bool,
  };

  static defaultProps = {
    animate: autoPlayGif,
  };

  render() {
    const { account, visibility, animate } = this.props;
    const icon = icons[visibility]

    const baseStyle = {
      backgroundImage: `url(${account.get(animate ? 'avatar' : 'avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-icon-base' style={baseStyle} />
        <div className='account__avatar-overlay-icon-overlay'><i className={`fa fa-fw fa-${icon}`} /></div>
      </div>
    );
  }
}
