import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { assetHost } from 'flavours/glitch/utils/config';

import { unicodeMapping } from '../features/emoji/emoji_unicode_mapping_light';

export default class AutosuggestEmoji extends PureComponent {

  static propTypes = {
    emoji: PropTypes.object.isRequired,
  };

  render () {
    const { emoji } = this.props;
    let url;

    if (emoji.custom) {
      url = emoji.imageUrl;
    } else {
      const mapping = unicodeMapping[emoji.native] || unicodeMapping[emoji.native.replace(/\uFE0F$/, '')];

      if (!mapping) {
        return null;
      }

      url = `${assetHost}/emoji/${mapping.filename}.svg`;
    }

    return (
      <div className='autosuggest-emoji'>
        <img
          className='emojione'
          src={url}
          alt={emoji.native || emoji.colons}
        />

        <div className='autosuggest-emoji__name'>{emoji.colons}</div>
      </div>
    );
  }

}
