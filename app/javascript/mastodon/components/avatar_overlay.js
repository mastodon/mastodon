import React from 'react';
import PropTypes from 'prop-types';

class AvatarOverlay extends React.PureComponent {

  static propTypes = {
    staticSrc: PropTypes.string.isRequired,
    overlaySrc: PropTypes.string.isRequired,
  };

  render() {
    const { staticSrc, overlaySrc } = this.props;

    const baseStyle = {
      backgroundImage: `url(${staticSrc})`,
    };

    const overlayStyle = {
      backgroundImage: `url(${overlaySrc})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-base' style={baseStyle} />
        <div className='account__avatar-overlay-overlay' style={overlayStyle} />
      </div>
    );
  }

}

export default AvatarOverlay;
