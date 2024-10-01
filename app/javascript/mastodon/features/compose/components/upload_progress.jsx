import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import spring from 'react-motion/lib/spring';

import UploadFileIcon from '@/material-icons/400-24px/upload_file.svg?react';
import { Icon }  from 'mastodon/components/icon';

import Motion from '../../ui/util/optional_motion';

export const UploadProgress = ({ active, progress, isProcessing }) => {
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
      <Icon id='upload' icon={UploadFileIcon} />

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
};

UploadProgress.propTypes = {
  active: PropTypes.bool,
  progress: PropTypes.number,
  isProcessing: PropTypes.bool,
};
