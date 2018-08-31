//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import spring from 'react-motion/lib/spring';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';
import { searchEnabled } from 'flavours/glitch/util/initial_state';

//  Messages.
const messages = defineMessages({
  format: {
    defaultMessage: 'Advanced search format',
    id: 'search_popout.search_format',
  },
  hashtag: {
    defaultMessage: 'hashtag',
    id: 'search_popout.tips.hashtag',
  },
  status: {
    defaultMessage: 'status',
    id: 'search_popout.tips.status',
  },
  text: {
    defaultMessage: 'Simple text returns matching display names, usernames and hashtags',
    id: 'search_popout.tips.text',
  },
  full_text: {
    defaultMessage: 'Simple text returns statuses you have written, favourited, boosted, or have been mentioned in, as well as matching usernames, display names, and hashtags.',
    id: 'search_popout.tips.full_text',
  },
  user: {
    defaultMessage: 'user',
    id: 'search_popout.tips.user',
  },
});

//  The spring used by our motion.
const motionSpring = spring(1, { damping: 35, stiffness: 400 });

//  The component.
export default function DrawerSearchPopout ({ style }) {

  //  The result.
  return (
    <div
      className='drawer--search--popout'
      style={{
        ...style,
        position: 'absolute',
        width: 285,
      }}
    >
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
            style={{
              opacity: opacity,
              transform: `scale(${scaleX}, ${scaleY})`,
            }}
          >
            <h4><FormattedMessage {...messages.format} /></h4>
            <ul>
              <li>
                <em>#example</em>
                {' '}
                <FormattedMessage {...messages.hashtag} />
              </li>
              <li>
                <em>@username@domain</em>
                {' '}
                <FormattedMessage {...messages.user} />
              </li>
              <li>
                <em>URL</em>
                {' '}
                <FormattedMessage {...messages.user} />
              </li>
              <li>
                <em>URL</em>
                {' '}
                <FormattedMessage {...messages.status} />
              </li>
            </ul>
            { searchEnabled ? <FormattedMessage {...messages.full_text} /> : <FormattedMessage {...messages.text} /> }
          </div>
        )}
      </Motion>
    </div>
  );
}

//  Props.
DrawerSearchPopout.propTypes = { style: PropTypes.object };
