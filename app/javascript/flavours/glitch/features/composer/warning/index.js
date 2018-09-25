import React from 'react';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import { defineMessages, FormattedMessage } from 'react-intl';
import { profileLink } from 'flavours/glitch/util/backend_links';

//  This is the spring used with our motion.
const motionSpring = spring(1, { damping: 35, stiffness: 400 });

//  Messages.
const messages = defineMessages({
  disclaimer: {
    defaultMessage: 'Your account is not {locked}. Anyone can follow you to view your follower-only posts.',
    id: 'compose_form.lock_disclaimer',
  },
  locked: {
    defaultMessage: 'locked',
    id: 'compose_form.lock_disclaimer.lock',
  },
});

//  The component.
export default function ComposerWarning () {
  let lockedLink = <FormattedMessage {...messages.locked} />;
  if (profileLink !== undefined) {
    lockedLink = <a href={profileLink}>{lockedLink}</a>;
  }
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
            values={{ locked: lockedLink }}
          />
        </div>
      )}
    </Motion>
  );
}

ComposerWarning.propTypes = {};
