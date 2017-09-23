import React from 'react';
import PropTypes from 'prop-types';
import { toCodePoint } from '../emoji';

const assetHost = process.env.CDN_HOST || '';

export default class AutosuggestEmoji extends React.PureComponent {

  static propTypes = {
    emoji: PropTypes.object.isRequired,
  };

  render () {
    const { emoji } = this.props;

    return (
      <div className='autosuggest-emoji'>
        <img
          className='emojione'
          src={emoji.custom ? emoji.imageUrl : `${assetHost}/emoji/${toCodePoint(emoji.native)}.svg`}
          alt={emoji.native}
        />

        {emoji.colons}
      </div>
    );
  }

}
