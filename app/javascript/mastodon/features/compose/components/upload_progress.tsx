import { FormattedMessage } from 'react-intl';

import { animated, useSpring } from '@react-spring/web';

import UploadFileIcon from '@/material-icons/400-24px/upload_file.svg?react';
import { Icon } from 'mastodon/components/icon';
import { reduceMotion } from 'mastodon/initial_state';

interface UploadProgressProps {
  active: boolean;
  progress: number;
  isProcessing: boolean;
}

export const UploadProgress: React.FC<UploadProgressProps> = ({
  active,
  progress,
  isProcessing,
}) => {
  const styles = useSpring({
    from: { width: '0%' },
    to: { width: `${progress}%` },
    reset: true,
    immediate: reduceMotion,
  });
  if (!active) {
    return null;
  }

  let message;

  if (isProcessing) {
    message = (
      <FormattedMessage
        id='upload_progress.processing'
        defaultMessage='Processing…'
      />
    );
  } else {
    message = (
      <FormattedMessage
        id='upload_progress.label'
        defaultMessage='Uploading…'
      />
    );
  }

  return (
    <div className='upload-progress'>
      <Icon id='upload' icon={UploadFileIcon} />

      <div className='upload-progress__message'>
        {message}

        <div className='upload-progress__backdrop'>
          <animated.div className='upload-progress__tracker' style={styles} />
        </div>
      </div>
    </div>
  );
};
