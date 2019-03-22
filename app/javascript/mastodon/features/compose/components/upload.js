import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import classNames from 'classnames';

const messages = defineMessages({
  description: { id: 'upload_form.description', defaultMessage: 'Describe for the visually impaired' },
});

export default @injectIntl
class Upload extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    onUndo: PropTypes.func.isRequired,
    onDescriptionChange: PropTypes.func.isRequired,
    onOpenFocalPoint: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
  };

  state = {
    hovered: false,
    focused: false,
    dirtyDescription: null,
  };

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }
  }

  handleSubmit = () => {
    this.handleInputBlur();
    this.props.onSubmit(this.context.router.history);
  }

  handleUndoClick = e => {
    e.stopPropagation();
    this.props.onUndo(this.props.media.get('id'));
  }

  handleFocalPointClick = e => {
    e.stopPropagation();
    this.props.onOpenFocalPoint(this.props.media.get('id'));
  }

  handleInputChange = e => {
    this.setState({ dirtyDescription: e.target.value });
  }

  handleMouseEnter = () => {
    this.setState({ hovered: true });
  }

  handleMouseLeave = () => {
    this.setState({ hovered: false });
  }

  handleInputFocus = () => {
    this.setState({ focused: true });
  }

  handleClick = () => {
    this.setState({ focused: true });
  }

  handleInputBlur = () => {
    const { dirtyDescription } = this.state;

    this.setState({ focused: false, dirtyDescription: null });

    if (dirtyDescription !== null) {
      this.props.onDescriptionChange(this.props.media.get('id'), dirtyDescription);
    }
  }

  render () {
    const { intl, media } = this.props;
    const active          = this.state.hovered || this.state.focused;
    const description     = this.state.dirtyDescription || (this.state.dirtyDescription !== '' && media.get('description')) || '';
    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;

    return (
      <div className='compose-form__upload' tabIndex='0' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} onClick={this.handleClick} role='button'>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
          {({ scale }) => (
            <div className='compose-form__upload-thumbnail' style={{ transform: `scale(${scale})`, backgroundImage: `url(${media.get('preview_url')})`, backgroundPosition: `${x}% ${y}%` }}>
              <div className={classNames('compose-form__upload__actions', { active })}>
                <button className='icon-button' onClick={this.handleUndoClick}><i className='fa fa-times' /> <FormattedMessage id='upload_form.undo' defaultMessage='Delete' /></button>
                {media.get('type') === 'image' && <button className='icon-button' onClick={this.handleFocalPointClick}><i className='fa fa-crosshairs' /> <FormattedMessage id='upload_form.focus' defaultMessage='Crop' /></button>}
              </div>

              <div className={classNames('compose-form__upload-description', { active })}>
                <label>
                  <span style={{ display: 'none' }}>{intl.formatMessage(messages.description)}</span>

                  <textarea
                    placeholder={intl.formatMessage(messages.description)}
                    value={description}
                    maxLength={420}
                    onFocus={this.handleInputFocus}
                    onChange={this.handleInputChange}
                    onBlur={this.handleInputBlur}
                    onKeyDown={this.handleKeyDown}
                  />
                </label>
              </div>
            </div>
          )}
        </Motion>
      </div>
    );
  }

}
