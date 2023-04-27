import React from 'react';
import PropTypes from 'prop-types';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import Icon from 'mastodon/components/icon';
import { FormattedMessage } from 'react-intl';

export default class UploadProgress extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    progress: PropTypes.number,
    isProcessing: PropTypes.bool,
  };

  render () {
    const { active, progress, isProcessing } = this.props;

    if (!active) {
      return null;
    }

    let message;

    if (isProcessing) {
      message = <FormattedMessage id='upload_progress.processing' defaultMessage='Processing…' />;
    } else {
      message = <FormattedMessage id='upload_progress.label' defaultMessage='Uploading…' />;
    }

    return (
      <div className='upload-progress'>
        <div className='upload-progress__icon'>
          <Icon id='upload' />
        </div>

        <div className='upload-progress__message'>
          {message}

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
