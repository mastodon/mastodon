import React from 'react';
import PropTypes from 'prop-types';
import { unicodeMapping } from '../emojione_light';

const assetHost = process.env.CDN_HOST || '';

export default class AutosuggestEmoji extends React.PureComponent {

  static propTypes = {
    emoji: PropTypes.object.isRequired,
  };

  render () {
    const { emoji } = this.props;
    let url;

    if (emoji.custom) {
      url = emoji.imageUrl;
    } else {
      const [ filename ] = unicodeMapping[emoji.native];
      url = `${assetHost}/emoji/${filename}.svg`;
    }

    return (
      <div className='autosuggest-emoji'>
        <img
          className='emojione'
          src={url}
          alt={emoji.native || emoji.colons}
        />

        {emoji.colons}
      </div>
    );
  }

}
