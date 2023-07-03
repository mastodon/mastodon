import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import spring from 'react-motion/lib/spring';

import { Icon }  from 'mastodon/components/icon';

import Motion from '../../ui/util/optional_motion';

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
  };

  handleFocalPointClick = e => {
    e.stopPropagation();
    this.props.onOpenFocalPoint(this.props.media.get('id'));
  };

  render () {
    const { media } = this.props;

    if (!media) {
      return null;
    }

    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);
    const x = ((focusX /  2) + .5) * 100;
    const y = ((focusY / -2) + .5) * 100;

    return (
      <div className='compose-form__upload'>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
          {({ scale }) => (
            <div className='compose-form__upload-thumbnail' style={{ transform: `scale(${scale})`, backgroundImage: `url(${media.get('preview_url')})`, backgroundPosition: `${x}% ${y}%` }}>
              <div className='compose-form__upload__actions'>
                <button type='button' className='icon-button' onClick={this.handleUndoClick}><Icon id='times' /> <FormattedMessage id='upload_form.undo' defaultMessage='Delete' /></button>
                <button type='button' className='icon-button' onClick={this.handleFocalPointClick}><Icon id='pencil' /> <FormattedMessage id='upload_form.edit' defaultMessage='Edit' /></button>
              </div>

              {(media.get('description') || '').length === 0 && (
                <div className='compose-form__upload__warning'>
                  <button type='button' className='icon-button' onClick={this.handleFocalPointClick}><Icon id='info-circle' /> <FormattedMessage id='upload_form.description_missing' defaultMessage='No description added' /></button>
                </div>
              )}
            </div>
          )}
        </Motion>
      </div>
    );
  }

}
