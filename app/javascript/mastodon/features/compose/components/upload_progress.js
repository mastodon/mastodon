import React from 'react';
import PropTypes from 'prop-types';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import { FormattedMessage } from 'react-intl';

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
      <div className='upload-progress'>
        <div className='upload-progress__icon'>
          <i className='fa fa-upload' />
        </div>

        <div className='upload-progress__message'>
          <FormattedMessage id='upload_progress.label' defaultMessage='Uploading...' />

          <div className='upload-progress__backdrop'>
            <Motion defaultStyle={{ width: 0 }} style={{ width: spring(progress) }}>
              {({ width }) =>
                <div className='upload-progress__tracker' style={{ width: `${width}%` }} />
              }
            </Motion>
          </div>
        </div>
      </div>
    );
  }

}
