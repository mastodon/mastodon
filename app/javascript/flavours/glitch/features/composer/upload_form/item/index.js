//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import spring from 'react-motion/lib/spring';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  Messages.
const messages = defineMessages({
  undo: {
    defaultMessage: 'Undo',
    id: 'upload_form.undo',
  },
  description: {
    defaultMessage: 'Describe for the visually impaired',
    id: 'upload_form.description',
  },
});

//  Handlers.
const handlers = {

  //  On blur, we save the description for the media item.
  handleBlur () {
    const {
      id,
      onChangeDescription,
    } = this.props;
    const { dirtyDescription } = this.state;
    if (id && onChangeDescription && dirtyDescription !== null) {
      this.setState({
        dirtyDescription: null,
        focused: false,
      });
      onChangeDescription(id, dirtyDescription);
    }
  },

  //  When the value of our description changes, we store it in the
  //  temp value `dirtyDescription` in our state.
  handleChange ({ target: { value } }) {
    this.setState({ dirtyDescription: value });
  },

  //  Records focus on the media item.
  handleFocus () {
    this.setState({ focused: true });
  },

  //  Records the start of a hover over the media item.
  handleMouseEnter () {
    this.setState({ hovered: true });
  },

  //  Records the end of a hover over the media item.
  handleMouseLeave () {
    this.setState({ hovered: false });
  },

  //  Removes the media item.
  handleRemove () {
    const {
      id,
      onRemove,
    } = this.props;
    if (id && onRemove) {
      onRemove(id);
    }
  },
};

//  The component.
export default class ComposerUploadFormItem extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = {
      hovered: false,
      focused: false,
      dirtyDescription: null,
    };
  }

  //  Rendering.
  render () {
    const {
      handleBlur,
      handleChange,
      handleFocus,
      handleMouseEnter,
      handleMouseLeave,
      handleRemove,
    } = this.handlers;
    const {
      description,
      intl,
      preview,
    } = this.props;
    const {
      focused,
      hovered,
      dirtyDescription,
    } = this.state;
    const computedClass = classNames('composer--upload_form--item', { active: hovered || focused });

    //  The result.
    return (
      <div
        className={computedClass}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
      >
        <Motion
          defaultStyle={{ scale: 0.8 }}
          style={{
            scale: spring(1, {
              stiffness: 180,
              damping: 12,
            }),
          }}
        >
          {({ scale }) => (
            <div
              style={{
                transform: `scale(${scale})`,
                backgroundImage: preview ? `url(${preview})` : null,
              }}
            >
              <IconButton
                className='close'
                icon='times'
                onClick={handleRemove}
                size={36}
                title={intl.formatMessage(messages.undo)}
              />
              <label>
                <span style={{ display: 'none' }}><FormattedMessage {...messages.description} /></span>
                <input
                  maxLength={420}
                  onBlur={handleBlur}
                  onChange={handleChange}
                  onFocus={handleFocus}
                  placeholder={intl.formatMessage(messages.description)}
                  type='text'
                  value={dirtyDescription || description || ''}
                />
              </label>
            </div>
          )}
        </Motion>
      </div>
    );
  }

}

//  Props.
ComposerUploadFormItem.propTypes = {
  description: PropTypes.string,
  id: PropTypes.string,
  intl: PropTypes.object.isRequired,
  onChangeDescription: PropTypes.func,
  onRemove: PropTypes.func,
  preview: PropTypes.string,
};
