import Immutable from 'immutable';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import MediaGallery from './media_gallery';

export default class StatusMediaGallery extends ImmutablePureComponent {

  static propTypes = {
    card: ImmutablePropTypes.map,
    status: ImmutablePropTypes.map.isRequired,
  }

  render () {
    const { card, status, ...props } = this.props;
    let mediaProperty = status.get('media_attachments');

    if (status.get('spoiler_text').length === 0 &&
        card !== undefined && card.get('type') === 'photo') {
      mediaProperty = mediaProperty.push(Immutable.fromJS({
        id: 'card',
        type: 'image',
        url: card.get('embed_url'),
        preview_url: card.get('image'),
        description: card.get('title'),
        meta: {
          original: {
            width: card.get('width'),
            height: card.get('height'),
          },
        },
      }));
    }

    return (
      <MediaGallery
        sensitive={status.get('sensitive')}
        media={mediaProperty}
        {...props}
      />
    );
  }

}
