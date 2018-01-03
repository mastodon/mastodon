//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage } from 'react-intl';

//  Components.
import Collapsable from 'flavours/glitch/components/collapsable';

//  Utils.
import {
  assignHandlers,
  hiddenComponent,
} from 'flavours/glitch/util/react_helpers';

//  Messages.
const messages = defineMessages({
  placeholder: {
    defaultMessage: 'Write your warning here',
    id: 'compose_form.spoiler_placeholder',
  },
});

//  Handlers.
const handlers = {

  //  Handles a keypress.
  handleKeyDown ({
    ctrlKey,
    keyCode,
    metaKey,
  }) {
    const { onSubmit } = this.props;

    //  We submit the status on control/meta + enter.
    if (onSubmit && keyCode === 13 && (ctrlKey || metaKey)) {
      onSubmit();
    }
  },
};

//  The component.
export default class ComposerSpoiler extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
  }

  //  Rendering.
  render () {
    const { handleKeyDown } = this.handlers;
    const {
      hidden,
      intl,
      onChange,
      text,
    } = this.props;

    //  The result.
    return (
      <Collapsable
        isVisible={!hidden}
        fullHeight={50}
      >
        <label className='composer--spoiler'>
          <span {...hiddenComponent}>
            <FormattedMessage {...messages.placeholder} />
          </span>
          <input
            id='glitch.composer.spoiler.input'
            onChange={onChange}
            onKeyDown={handleKeyDown}
            placeholder={intl.formatMessage(messages.placeholder)}
            type='text'
            value={text}
          />
        </label>
      </Collapsable>
    );
  }

}

//  Props.
ComposerSpoiler.propTypes = {
  hidden: PropTypes.bool,
  intl: PropTypes.object.isRequired,
  onChange: PropTypes.func,
  onSubmit: PropTypes.func,
  text: PropTypes.string,
};
