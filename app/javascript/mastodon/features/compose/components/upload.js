import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';

export default class Upload extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    onUndo: PropTypes.func.isRequired,
    onOpenFocalPoint: PropTypes.func.isRequired,
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
    const { media } = this.props;
    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;

    return (
      <div className='compose-form__upload' tabIndex='0' role='button'>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
          {({ scale }) => (
            <div className='compose-form__upload-thumbnail' style={{ transform: `scale(${scale})`, backgroundImage: `url(${media.get('preview_url')})`, backgroundPosition: `${x}% ${y}%` }}>
              <div className={classNames('compose-form__upload__actions', { active: true })}>
                <button className='icon-button' onClick={this.handleUndoClick}><Icon id='times' /> <FormattedMessage id='upload_form.undo' defaultMessage='Delete' /></button>
                <button className='icon-button' onClick={this.handleFocalPointClick}><Icon id='pencil' /> <FormattedMessage id='upload_form.edit' defaultMessage='Edit' /></button>
              </div>
            </div>
          )}
        </Motion>
      </div>
    );
  }

}
