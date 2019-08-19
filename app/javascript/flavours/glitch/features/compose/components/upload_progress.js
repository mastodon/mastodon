import React from 'react';
import PropTypes from 'prop-types';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import Icon from 'flavours/glitch/components/icon';

export default class UploadProgress extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    progress: PropTypes.number,
    icon: PropTypes.string.isRequired,
    message: PropTypes.node.isRequired,
  };

  render () {
    const { active, progress, icon, message } = this.props;

    if (!active) {
      return null;
    }

    return (
      <div className='composer--upload_form--progress'>
        <Icon icon={icon} />

        <div className='message'>
          {message}

          <div className='backdrop'>
            <Motion defaultStyle={{ width: 0 }} style={{ width: spring(progress) }}>
              {({ width }) =>
                (<div className='tracker' style={{ width: `${width}%` }}
                />)
              }
            </Motion>
          </div>
        </div>
      </div>
    );
  }

}
