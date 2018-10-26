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
import { isUserTouching } from 'flavours/glitch/util/is_mobile';

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
  crop: {
    defaultMessage: 'Crop',
    id: 'upload_form.focus',
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

    this.setState({ dirtyDescription: null, focused: false });

    if (id && onChangeDescription && dirtyDescription !== null) {
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

  //  Opens the focal point modal.
  handleFocalPointClick () {
    const {
      id,
      onOpenFocalPointModal,
    } = this.props;
    if (id && onOpenFocalPointModal) {
      onOpenFocalPointModal(id);
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
      handleFocalPointClick,
    } = this.handlers;
    const {
      intl,
      preview,
      focusX,
      focusY,
      mediaType,
    } = this.props;
    const {
      focused,
      hovered,
      dirtyDescription,
    } = this.state;
    const active = hovered || focused || isUserTouching();
    const computedClass = classNames('composer--upload_form--item', { active });
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;
    const description = dirtyDescription || (dirtyDescription !== '' && this.props.description) || '';

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
                backgroundPosition: `${x}% ${y}%`
              }}
            >
              <div className={classNames('composer--upload_form--actions', { active })}>
                <button className='icon-button' onClick={handleRemove}>
                  <i className='fa fa-times' /> <FormattedMessage {...messages.undo} />
                </button>
                {mediaType === 'image' && <button className='icon-button' onClick={handleFocalPointClick}><i className='fa fa-crosshairs' /> <FormattedMessage {...messages.crop} /></button>}
              </div>
              <label>
                <span style={{ display: 'none' }}><FormattedMessage {...messages.description} /></span>
                <input
                  maxLength={420}
                  onBlur={handleBlur}
                  onChange={handleChange}
                  onFocus={handleFocus}
                  placeholder={intl.formatMessage(messages.description)}
                  type='text'
                  value={description}
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
  onChangeDescription: PropTypes.func.isRequired,
  onOpenFocalPointModal: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired,
  focusX: PropTypes.number,
  focusY: PropTypes.number,
  mediaType: PropTypes.string,
  preview: PropTypes.string,
};
