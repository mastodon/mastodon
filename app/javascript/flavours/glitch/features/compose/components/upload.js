import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import Icon from 'flavours/glitch/components/icon';
import { isUserTouching } from 'flavours/glitch/util/is_mobile';

export default class Upload extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    onUndo: PropTypes.func.isRequired,
    onOpenFocalPoint: PropTypes.func.isRequired,
    isEditingStatus: PropTypes.func.isRequired,
  };

  handleUndoClick = e => {
    e.stopPropagation();
    this.props.onUndo(this.props.media.get('id'));
  }

  handleFocalPointClick = e => {
    e.stopPropagation();
    this.props.onOpenFocalPoint(this.props.media.get('id'));
  }

  render () {
    const { intl, media, isEditingStatus } = this.props;
    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;

    return (
      <div className='composer--upload_form--item' tabIndex='0' role='button'>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12, }) }}>
          {({ scale }) => (
            <div style={{ transform: `scale(${scale})`, backgroundImage: `url(${media.get('preview_url')})`, backgroundPosition: `${x}% ${y}%` }}>
              <div className='composer--upload_form--actions'>
                <button className='icon-button' onClick={this.handleUndoClick}><Icon id='times' /> <FormattedMessage id='upload_form.undo' defaultMessage='Delete' /></button>
                {!isEditingStatus && (<button className='icon-button' onClick={this.handleFocalPointClick}><Icon id='pencil' /> <FormattedMessage id='upload_form.edit' defaultMessage='Edit' /></button>)}
              </div>

              {(media.get('description') || '').length === 0 && (
                <div className='composer--upload_form--item__warning'>
                  <button className='icon-button' onClick={this.handleFocalPointClick}><Icon id='info-circle' /> <FormattedMessage id='upload_form.description_missing' defaultMessage='No description added' /></button>
                </div>
              )}
            </div>
          )}
        </Motion>
      </div>
    );
  }

}
