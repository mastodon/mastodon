import React from 'react';
import ReactSwipeableViews from 'react-swipeable-views';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Video from 'mastodon/features/video';
import classNames from 'classnames';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from 'mastodon/components/icon_button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImageLoader from './image_loader';
import Icon from 'mastodon/components/icon';
import GIFV from 'mastodon/components/gifv';
import { disableSwiping } from 'mastodon/initial_state';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
});

export const previewState = 'previewMediaModal';

export default @injectIntl
class MediaModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.list.isRequired,
    status: ImmutablePropTypes.map,
    index: PropTypes.number.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  state = {
    index: null,
    navigationHidden: false,
  };

  handleSwipe = (index) => {
    this.setState({ index: index % this.props.media.size });
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

  handleKeyDown = (e) => {
    switch(e.key) {
    case 'ArrowLeft':
      this.handlePrevClick();
      e.preventDefault();
      e.stopPropagation();
      break;
    case 'ArrowRight':
      this.handleNextClick();
      e.preventDefault();
      e.stopPropagation();
      break;
    }
  }

  componentDidMount () {
    window.addEventListener('keydown', this.handleKeyDown, false);

    if (this.context.router) {
      const history = this.context.router.history;

      history.push(history.location.pathname, previewState);

      this.unlistenHistory = history.listen(() => {
        this.props.onClose();
      });
    }
  }

  componentWillUnmount () {
    window.removeEventListener('keydown', this.handleKeyDown);

    if (this.context.router) {
      this.unlistenHistory();

      if (this.context.router.history.location.state === previewState) {
        this.context.router.history.goBack();
      }
    }
  }

  getIndex () {
    return this.state.index !== null ? this.state.index : this.props.index;
  }

  toggleNavigation = () => {
    this.setState(prevState => ({
      navigationHidden: !prevState.navigationHidden,
    }));
  };

  handleStatusClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
    }
  }

  render () {
    const { media, status, intl, onClose } = this.props;
    const { navigationHidden } = this.state;

    const index = this.getIndex();
    let pagination = [];

    const leftNav  = media.size > 1 && <button tabIndex='0' className='media-modal__nav media-modal__nav--left' onClick={this.handlePrevClick} aria-label={intl.formatMessage(messages.previous)}><Icon id='chevron-left' fixedWidth /></button>;
    const rightNav = media.size > 1 && <button tabIndex='0' className='media-modal__nav  media-modal__nav--right' onClick={this.handleNextClick} aria-label={intl.formatMessage(messages.next)}><Icon id='chevron-right' fixedWidth /></button>;

    if (media.size > 1) {
      pagination = media.map((item, i) => {
        const classes = ['media-modal__button'];
        if (i === index) {
          classes.push('media-modal__button--active');
        }
        return (<li className='media-modal__page-dot' key={i}><button tabIndex='0' className={classes.join(' ')} onClick={this.handleChangeIndex} data-index={i}>{i + 1}</button></li>);
      });
    }

    const content = media.map((image) => {
      const width  = image.getIn(['meta', 'original', 'width']) || null;
      const height = image.getIn(['meta', 'original', 'height']) || null;

      if (image.get('type') === 'image') {
        return (
          <ImageLoader
            previewSrc={image.get('preview_url')}
            src={image.get('url')}
            width={width}
            height={height}
            alt={image.get('description')}
            key={image.get('url')}
            onClick={this.toggleNavigation}
          />
        );
      } else if (image.get('type') === 'video') {
        const { time } = this.props;

        return (
          <Video
            preview={image.get('preview_url')}
            blurhash={image.get('blurhash')}
            src={image.get('url')}
            width={image.get('width')}
            height={image.get('height')}
            startTime={time || 0}
            onCloseVideo={onClose}
            detailed
            alt={image.get('description')}
            key={image.get('url')}
          />
        );
      } else if (image.get('type') === 'gifv') {
        return (
          <GIFV
            src={image.get('url')}
            width={width}
            height={height}
            key={image.get('preview_url')}
            alt={image.get('description')}
            onClick={this.toggleNavigation}
          />
        );
      }

      return null;
    }).toArray();

    // you can't use 100vh, because the viewport height is taller
    // than the visible part of the document in some mobile
    // browsers when it's address bar is visible.
    // https://developers.google.com/web/updates/2016/12/url-bar-resizing
    const swipeableViewsStyle = {
      width: '100%',
      height: '100%',
    };

    const containerStyle = {
      alignItems: 'center', // center vertically
    };

    const navigationClassName = classNames('media-modal__navigation', {
      'media-modal__navigation--hidden': navigationHidden,
    });

    return (
      <div className='modal-root__modal media-modal'>
        <div
          className='media-modal__closer'
          role='presentation'
          onClick={onClose}
        >
          <ReactSwipeableViews
            style={swipeableViewsStyle}
            containerStyle={containerStyle}
            onChangeIndex={this.handleSwipe}
            index={index}
            disabled={disableSwiping}
          >
            {content}
          </ReactSwipeableViews>
        </div>

        <div className={navigationClassName}>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={40} />

          {leftNav}
          {rightNav}

          {status && (
            <div className={classNames('media-modal__meta', { 'media-modal__meta--shifted': media.size > 1 })}>
              <a href={status.get('url')} onClick={this.handleStatusClick}><Icon id='comments' /> <FormattedMessage id='lightbox.view_context' defaultMessage='View context' /></a>
            </div>
          )}

          <ul className='media-modal__pagination'>
            {pagination}
          </ul>
        </div>
      </div>
    );
  }

}
