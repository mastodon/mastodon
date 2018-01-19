import React from 'react';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import { defineMessages, FormattedMessage } from 'react-intl';

//  This is the spring used with our motion.
const motionSpring = spring(1, { damping: 35, stiffness: 400 });

//  Messages.
const messages = defineMessages({
  disclaimer: {
    defaultMessage: 'This toot won\'t be listed under any hashtag as it is unlisted. Only public toots can be searched by hashtag.',
    id: 'compose_form.hashtag_warning',
  },
});

//  The component.
export default function ComposerHashtagWarning () {
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
          <FormattedMessage
            {...messages.disclaimer}
          />
        </div>
      )}
    </Motion>
  );
}

ComposerHashtagWarning.propTypes = {};
