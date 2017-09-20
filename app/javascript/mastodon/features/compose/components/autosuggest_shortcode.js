import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import emojione from 'emojione';

// This is bad, but I don't know how to make it work without importing the entirety of emojione.
// taken from some old version of mastodon before they gutted emojione to "emojione_light"
const shortnameToImage = str => str.replace(emojione.regShortNames, shortname => {
  if (typeof shortname === 'undefined' || shortname === '' || !(shortname in emojione.emojioneList)) {
    return shortname;
  }

  const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
  const alt     = emojione.convert(unicode.toUpperCase());

  return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${unicode}.svg" />`;
});

export default class AutosuggestShortcode extends ImmutablePureComponent {

  static propTypes = {
    shortcode: PropTypes.string.isRequired,
  };

  render () {
    const { shortcode } = this.props;

    let emoji = shortnameToImage(shortcode);

    return (
      <div className='autosuggest-account'>
        <div className='autosuggest-account-icon' dangerouslySetInnerHTML={{ __html: emoji }} />
        {shortcode}
      </div>
    );
  }

}
