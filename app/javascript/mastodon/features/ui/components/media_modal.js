import React from 'react';
import ReactSwipeableViews from 'react-swipeable-views';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import ExtendedVideoPlayer from '../../../components/extended_video_player';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImageLoader from './image_loader';

const VERTICAL_SWIPE_THRESHOLD_RATIO = 0.3;

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
});

@injectIntl
export default class MediaModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.list.isRequired,
    index: PropTypes.number.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    index: null,
    navigationShown: true,
    swiping: false,
    verticalSwipeDelta: 0,
  };

  closer = null;
  initialTouchPoint = null;
  verticalSwipeThreshold = -1; // need to be smaller than 0
  ignoreTouchMove = false;

  handleSwipe = (index) => {
    this.setState({ index: index % this.props.media.size });
  }

  handleSwitching = (i, s) => {
    // disable vertical swiping while horizontally swiped
    if (s === 'move') {
      this.ignoreTouchMove = true;
      this.setState({ verticalSwipeDelta: 0 });
    }
    if (s === 'end') this.ignoreTouchMove = false;
  }

  handleNextClick = () => {
    this.setState({ index: (this.getIndex() + 1) % this.props.media.size });
  }

  handlePrevClick = () => {
    this.setState({ index: (this.props.media.size + this.getIndex() - 1) % this.props.media.size });
  }

  handleChangeIndex = (e) => {
    const index = Number(e.currentTarget.getAttribute('data-index'));
    this.setState({ index: index % this.props.media.size });
  }

  handleKeyUp = (e) => {
    switch(e.key) {
    case 'ArrowLeft':
      this.handlePrevClick();
      break;
    case 'ArrowRight':
      this.handleNextClick();
      break;
    }
  }

  handleTouchStart = ev => {
    if (ev.touches.length !== 1) return;
    this.initialTouchPoint = ev.touches[0];
    this.setState({
      swiping: true,
      verticalSwipeDelta: 0,
    });
  }

  handleTouchMove = ev => {
    if (this.ignoreTouchMove) return;
    if (ev.touches.length !== 1) return;
    const p = ev.touches[0];
    this.setState({
      verticalSwipeDelta: p.clientY - this.initialTouchPoint.clientY,
    });
  }

  handleTouchEnd = ev => {
    if (ev.touches.length > 0) return;
    if (this.state.verticalSwipeDelta <= this.verticalSwipeThreshold)
      // FIXME モーダルが閉じるのに3秒くらいかかる
      setTimeout(this.props.onClose, 300);
    this.setState({ swiping: false });
  }

  componentDidMount () {
    this.verticalSwipeThreshold = -this.closer.clientHeight * VERTICAL_SWIPE_THRESHOLD_RATIO;

    window.addEventListener('keyup', this.handleKeyUp, false);

    this.closer.addEventListener('touchstart', this.handleTouchStart.bind(this));
    this.closer.addEventListener('touchmove', this.handleTouchMove.bind(this));
    this.closer.addEventListener('touchend', this.handleTouchEnd.bind(this));
  }

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  }

  getIndex () {
    return this.state.index !== null ? this.state.index : this.props.index;
  }

  render () {
    const { media, intl, onClose } = this.props;
    const { navigationShown, swiping, verticalSwipeDelta } = this.state;

    const index = this.getIndex();
    let pagination = [];

    const leftNav  = media.size > 1 && <button tabIndex='0' className='media-modal__nav media-modal__nav--left' onClick={this.handlePrevClick} aria-label={intl.formatMessage(messages.previous)}><i className='fa fa-fw fa-chevron-left' /></button>;
    const rightNav = media.size > 1 && <button tabIndex='0' className='media-modal__nav  media-modal__nav--right' onClick={this.handleNextClick} aria-label={intl.formatMessage(messages.next)}><i className='fa fa-fw fa-chevron-right' /></button>;

    if (media.size > 1) {
      pagination = media.map((item, i) => {
        const classes = ['media-modal__button'];
        if (i === index) {
          classes.push('media-modal__button--active');
        }
        return (<li className='media-modal__page-dot' key={i}><button tabIndex='0' className={classes.join(' ')} onClick={this.handleChangeIndex} data-index={i}>{i + 1}</button></li>);
      });
    }

    const switchNavigation = () => {
      this.setState({
        navigationShown: !navigationShown,
      });
    };

    const content = media.map((image) => {
      const width  = image.getIn(['meta', 'original', 'width']) || null;
      const height = image.getIn(['meta', 'original', 'height']) || null;

      if (image.get('type') === 'image') {
        return <ImageLoader previewSrc={image.get('preview_url')} src={image.get('url')} width={width} height={height} alt={image.get('description')} key={image.get('url')} onClick={switchNavigation} onScroll={this.cancelCloser} />;
      } else if (image.get('type') === 'gifv') {
        return <ExtendedVideoPlayer src={image.get('url')} muted controls={false} width={width} height={height} key={image.get('preview_url')} alt={image.get('description')} />;
      }

      return null;
    }).toArray();

    const containerStyle = {
      alignItems: 'center', // center vertically
    };

    const closerStyle = swiping ? {
      transform: `translateY(${Math.min(verticalSwipeDelta, 0)}px)`,
    } : {
      transform: `translateY(${verticalSwipeDelta <= this.verticalSwipeThreshold ? '-100%' : '0'})`,
      // FIXME better animation
      transition: 'transform 0.3s linear',
    };

    const navigationClassName = classNames('media-modal__navigation', {
      'media-modal__navigation--hidden': !navigationShown,
    });

    const setCloserRef = c => {
      this.closer = c;
    };

    return (
      <div className='modal-root__modal media-modal'>
        {/* FIXME onTouchXXX don't effect */}
        <div
          className='media-modal__closer'
          role='presentation'
          ref={setCloserRef}
          style={closerStyle}
          onClick={onClose}
          onTouchStart={this.handleTouchStart}
          onTouchMove={this.handleTouchMove}
          onTouchEnd={this.handleTouchEnd}
        >
          <div className='media-modal__content'>
            <ReactSwipeableViews
              style={{ height: '100%' }}
              containerStyle={containerStyle}
              onChangeIndex={this.handleSwipe}
              onSwitching={this.handleSwitching}
              index={index}
            >
              {content}
            </ReactSwipeableViews>
          </div>
        </div>
        <div className={navigationClassName}>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={32} />
          {leftNav}
          {rightNav}
          <ul className='media-modal__pagination'>
            {pagination}
          </ul>
        </div>
      </div>
    );
  }

}
