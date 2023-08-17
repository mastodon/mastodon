import PropTypes from 'prop-types';
import { useMemo, useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';

const domParser = new DOMParser();

// About two lines on desktop
const VISIBLE_HASHTAGS = 7;

export const HashtagBar = ({ hashtags, text }) => {
  const renderedHashtags = useMemo(() => {
    const body = domParser.parseFromString(text, 'text/html').documentElement;
    return [].filter.call(body.querySelectorAll('a[href]'), link => link.textContent[0] === '#' || (link.previousSibling?.textContent?.[link.previousSibling.textContent.length - 1] === '#')).map(node => node.textContent);
  }, [text]);

  const invisibleHashtags = useMemo(() => (
    hashtags.filter(hashtag => !renderedHashtags.some(textContent => textContent.localeCompare(`#${hashtag.get('name')}`, undefined, { sensitivity: 'accent' }) === 0 || textContent.localeCompare(hashtag.get('name'), undefined, { sensitivity: 'accent' }) === 0))
  ), [hashtags, renderedHashtags]);

  const [expanded, setExpanded] = useState(false);
  const handleClick = useCallback(() => setExpanded(true), []);

  if (invisibleHashtags.isEmpty()) {
    return null;
  }

  const revealedHashtags = expanded ? invisibleHashtags : invisibleHashtags.take(VISIBLE_HASHTAGS);

  return (
    <div className='hashtag-bar'>
      {revealedHashtags.map(hashtag => (
        <Link key={hashtag.get('name')} to={`/tags/${hashtag.get('name')}`}>
          #{hashtag.get('name')}
        </Link>
      ))}

      {!expanded && invisibleHashtags.size > VISIBLE_HASHTAGS && <button className='link-button' onClick={handleClick}><FormattedMessage id='hashtags.and_other' defaultMessage='…and {count, plural, other {# more}}' values={{ count: invisibleHashtags.size - VISIBLE_HASHTAGS }} /></button>}
    </div>
  );
};

HashtagBar.propTypes = {
  hashtags: ImmutablePropTypes.list,
  text: PropTypes.string,
};
