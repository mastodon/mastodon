import React from 'react';
import PropTypes from 'prop-types';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import { FormattedMessage } from 'react-intl';
import Icon from 'flavours/glitch/components/icon';

export default class UploadProgress extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    progress: PropTypes.number,
  };

  render () {
    const { active, progress } = this.props;

    if (!active) {
      return null;
    }

    return (
      <div className='composer--upload_form--progress'>
        <Icon icon='upload' />

        <div className='message'>
          <FormattedMessage id='upload_progress.label' defaultMessage='Uploading...' />

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
