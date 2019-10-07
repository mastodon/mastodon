import React, { PureComponent, Fragment } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { List as ImmutableList, fromJS } from 'immutable';
import { getLocale } from 'mastodon/locales';
import { getScrollbarWidth } from 'flavours/glitch/util/scrollbar';
import MediaGallery from 'flavours/glitch/components/media_gallery';
import Poll from 'flavours/glitch/components/poll';
import Hashtag from 'flavours/glitch/components/hashtag';
import ModalRoot from 'flavours/glitch/components/modal_root';
import MediaModal from 'flavours/glitch/features/ui/components/media_modal';
import Video from 'flavours/glitch/features/video';
import Card from 'flavours/glitch/features/status/components/card';
import Audio from 'flavours/glitch/features/audio';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

const MEDIA_COMPONENTS = { MediaGallery, Video, Card, Poll, Hashtag, Audio };

export default class MediaContainer extends PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    components: PropTypes.object.isRequired,
  };

  state = {
    media: null,
    index: null,
    time: null,
  };

  handleOpenMedia = (media, index) => {
    document.body.classList.add('with-modals--active');
    document.documentElement.style.marginRight = `${getScrollbarWidth()}px`;

    this.setState({ media, index });
  }

  handleOpenVideo = (video, time) => {
    const media = ImmutableList([video]);

    document.body.classList.add('with-modals--active');
    document.documentElement.style.marginRight = `${getScrollbarWidth()}px`;

    this.setState({ media, time });
  }

  handleCloseMedia = () => {
    document.body.classList.remove('with-modals--active');
    document.documentElement.style.marginRight = 0;

    this.setState({ media: null, index: null, time: null });
  }

  render () {
    const { locale, components } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Fragment>
          {[].map.call(components, (component, i) => {
            const componentName = component.getAttribute('data-component');
            const Component = MEDIA_COMPONENTS[componentName];
            const { media, card, poll, hashtag, ...props } = JSON.parse(component.getAttribute('data-props'));

            Object.assign(props, {
              ...(media   ? { media:   fromJS(media)   } : {}),
              ...(card    ? { card:    fromJS(card)    } : {}),
              ...(poll    ? { poll:    fromJS(poll)    } : {}),
              ...(hashtag ? { hashtag: fromJS(hashtag) } : {}),

              ...(componentName === 'Video' ? {
                onOpenVideo: this.handleOpenVideo,
              } : {
                onOpenMedia: this.handleOpenMedia,
              }),
            });

            return ReactDOM.createPortal(
              <Component {...props} key={`media-${i}`} />,
              component,
            );
          })}

          <ModalRoot onClose={this.handleCloseMedia}>
            {this.state.media && (
              <MediaModal
                media={this.state.media}
                index={this.state.index || 0}
                time={this.state.time}
                onClose={this.handleCloseMedia}
              />
            )}
          </ModalRoot>
        </Fragment>
      </IntlProvider>
    );
  }

}
