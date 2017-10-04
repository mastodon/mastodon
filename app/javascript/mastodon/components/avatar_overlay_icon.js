import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class AvatarOverlayIcon extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    icon: PropTypes.string.isRequired,
  };

  render() {
    const { account, icon } = this.props;

    const baseStyle = {
      backgroundImage: `url(${account.get('avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-icon-base' style={baseStyle} />
        <div className='account__avatar-overlay-icon-overlay'><i className={`fa fa-fw fa-${icon}`} /></div>
      </div>
    );
  }

}
