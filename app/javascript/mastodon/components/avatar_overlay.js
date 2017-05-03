import React from 'react';
import PropTypes from 'prop-types';

class AvatarOverlay extends React.PureComponent {
  render() {
    const {staticSrc, overlaySrc} = this.props;

    const baseStyle = {
      backgroundImage: `url(${staticSrc})`
    };

    const overlayStyle = {
      backgroundImage: `url(${overlaySrc})`
    };

    return (
      <div className='account__avatar-overlay'>
        <div className="account__avatar-overlay-base" style={baseStyle} />
        <div className="account__avatar-overlay-overlay" style={overlayStyle} />
      </div>
    );
  }
}

AvatarOverlay.propTypes = {
  staticSrc: PropTypes.string.isRequired,
  overlaySrc: PropTypes.string.isRequired,
};

export default AvatarOverlay;
