//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Messages.
const messages = defineMessages({
  localOnly: {
    defaultMessage: 'This post is local-only',
    id: 'advanced_options.local-only.tooltip',
  },
  threadedMode: {
    defaultMessage: 'Threaded mode enabled',
    id: 'advanced_options.threaded_mode.tooltip',
  },
});

//  We use an array of tuples here instead of an object because it
//  preserves order.
const iconMap = [
  ['do_not_federate', 'home', messages.localOnly],
  ['threaded_mode', 'comments', messages.threadedMode],
];

//  The component.
export default function ComposerTextareaIcons ({
  advancedOptions,
  intl,
}) {

  //  The result. We just map every active option to its icon.
  return (
    <div className='composer--textarea--icons'>
      {advancedOptions ? iconMap.map(
        ([key, icon, message]) => advancedOptions.get(key) ? (
          <span
            className='textarea_icon'
            key={key}
            title={intl.formatMessage(message)}
          >
            <Icon
              fullwidth
              icon={icon}
            />
          </span>
        ) : null
      ) : null}
    </div>
  );
}

//  Props.
ComposerTextareaIcons.propTypes = {
  advancedOptions: ImmutablePropTypes.map,
  intl: PropTypes.object.isRequired,
};
