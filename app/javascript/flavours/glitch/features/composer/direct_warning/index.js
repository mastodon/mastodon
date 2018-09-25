import React from 'react';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import { defineMessages, FormattedMessage } from 'react-intl';
import { termsLink} from 'flavours/glitch/util/backend_links';

//  This is the spring used with our motion.
const motionSpring = spring(1, { damping: 35, stiffness: 400 });

//  Messages.
const messages = defineMessages({
  disclaimer: {
    defaultMessage: 'This toot will only be sent to all the mentioned users.',
    id: 'compose_form.direct_message_warning',
  },
  learn_more: {
    defaultMessage: 'Learn more',
    id: 'compose_form.direct_message_warning_learn_more'
  }
});

//  The component.
export default function ComposerDirectWarning () {
  return (
    <Motion
      defaultStyle={{
        opacity: 0,
        scaleX: 0.85,
        scaleY: 0.75,
      }}
      style={{
        opacity: motionSpring,
        scaleX: motionSpring,
        scaleY: motionSpring,
      }}
    >
      {({ opacity, scaleX, scaleY }) => (
        <div
          className='composer--warning'
          style={{
            opacity: opacity,
            transform: `scale(${scaleX}, ${scaleY})`,
          }}
        >
          <span>
            <FormattedMessage {...messages.disclaimer} />
            { termsLink !== undefined && <a href={termsLink} target='_blank'><FormattedMessage {...messages.learn_more} /></a> }
          </span>
        </div>
      )}
    </Motion>
  );
}

ComposerDirectWarning.propTypes = {};
