//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage } from 'react-intl';

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
    altKey,
  }) {
    const { onSubmit, onSecondarySubmit } = this.props;

    //  We submit the status on control/meta + enter.
    if (onSubmit && keyCode === 13 && (ctrlKey || metaKey)) {
      onSubmit();
    }

    // Submit the status with secondary visibility on alt + enter.
    if (onSecondarySubmit && keyCode === 13 && altKey) {
      onSecondarySubmit();
    }
  },

  handleRefSpoilerText (spoilerText) {
    this.spoilerText = spoilerText;
  },

  //  When the escape key is released, we focus the UI.
  handleKeyUp ({ key }) {
    if (key === 'Escape') {
      document.querySelector('.ui').parentElement.focus();
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
    const { handleKeyDown, handleKeyUp, handleRefSpoilerText } = this.handlers;
    const {
      hidden,
      intl,
      onChange,
      text,
    } = this.props;

    //  The result.
    return (
      <div className={`composer--spoiler ${hidden ? '' : 'composer--spoiler--visible'}`}>
        <label>
          <span {...hiddenComponent}>
            <FormattedMessage {...messages.placeholder} />
          </span>
          <input
            id='glitch.composer.spoiler.input'
            onChange={onChange}
            onKeyDown={handleKeyDown}
            onKeyUp={handleKeyUp}
            placeholder={intl.formatMessage(messages.placeholder)}
            type='text'
            value={text}
            ref={handleRefSpoilerText}
          />
        </label>
      </div>
    );
  }

}

//  Props.
ComposerSpoiler.propTypes = {
  hidden: PropTypes.bool,
  intl: PropTypes.object.isRequired,
  onChange: PropTypes.func,
  onSubmit: PropTypes.func,
  onSecondarySubmit: PropTypes.func,
  text: PropTypes.string,
};
