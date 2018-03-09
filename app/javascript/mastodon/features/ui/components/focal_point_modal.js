import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import ImageLoader from './image_loader';
import classNames from 'classnames';
import { changeUploadCompose } from '../../../actions/compose';
import { getPointerPosition } from '../../video';

const mapStateToProps = (state, { id }) => ({
  media: state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id),
});

const mapDispatchToProps = (dispatch, { id }) => ({

  onSave: (x, y) => {
    dispatch(changeUploadCompose(id, { focus: `${x.toFixed(2)},${y.toFixed(2)}` }));
  },

});

@connect(mapStateToProps, mapDispatchToProps)
export default class FocalPointModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
  };

  state = {
    x: 0,
    y: 0,
    focusX: 0,
    focusY: 0,
    dragging: false,
  };

  componentWillMount () {
    this.updatePositionFromMedia(this.props.media);
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.media.get('id') !== nextProps.media.get('id')) {
      this.updatePositionFromMedia(nextProps.media);
    }
  }

  componentWillUnmount () {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
  }

  handleMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('mouseup', this.handleMouseUp);

    this.updatePosition(e);
    this.setState({ dragging: true });
  }

  handleMouseMove = e => {
    this.updatePosition(e);
  }

  handleMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);

    this.setState({ dragging: false });
    this.props.onSave(this.state.focusX, this.state.focusY);
  }

  updatePosition = e => {
    const { x, y } = getPointerPosition(this.node, e);
    const focusX   = (x - .5) *  2;
    const focusY   = (y - .5) * -2;

    this.setState({ x, y, focusX, focusY });
  }

  updatePositionFromMedia = media => {
    const focusX = media.getIn(['meta', 'focus', 'x']);
    const focusY = media.getIn(['meta', 'focus', 'y']);

    if (focusX && focusY) {
      const x = (focusX /  2) + .5;
      const y = (focusY / -2) + .5;

      this.setState({ x, y, focusX, focusY });
    } else {
      this.setState({ x: 0.5, y: 0.5, focusX: 0, focusY: 0 });
    }
  }

  setRef = c => {
    this.node = c;
  }

  render () {
    const { media } = this.props;
    const { x, y, dragging } = this.state;

    const width  = media.getIn(['meta', 'original', 'width']) || null;
    const height = media.getIn(['meta', 'original', 'height']) || null;

    return (
      <div className='modal-root__modal video-modal'>
        <div className={classNames('focal-point', { dragging })} ref={this.setRef}>
          <ImageLoader
            previewSrc={media.get('preview_url')}
            src={media.get('url')}
            width={width}
            height={height}
          />

          <div className='focal-point__reticle' style={{ top: `${y * 100}%`, left: `${x * 100}%` }} />
          <div className='focal-point__overlay' onMouseDown={this.handleMouseDown} />
        </div>
      </div>
    );
  }

}
