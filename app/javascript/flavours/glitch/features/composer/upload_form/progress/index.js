//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import {
  defineMessages,
  FormattedMessage,
} from 'react-intl';
import spring from 'react-motion/lib/spring';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';

//  Messages.
const messages = defineMessages({
  upload: {
    defaultMessage: 'Uploading...',
    id: 'upload_progress.label',
  },
});

//  The component.
export default function ComposerUploadFormProgress ({ progress }) {

  //  The result.
  return (
    <div className='composer--upload_form--progress'>
      <Icon icon='upload' />
      <div className='message'>
        <FormattedMessage {...messages.upload} />
        <div className='backdrop'>
          <Motion
            defaultStyle={{ width: 0 }}
            style={{ width: spring(progress) }}
          >
            {({ width }) =>
              <div
                className='tracker'
                style={{ width: `${width}%` }}
              />
            }
          </Motion>
        </div>
      </div>
    </div>
  );
}

//  Props.
ComposerUploadFormProgress.propTypes = { progress: PropTypes.number };
