import { useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import type { List, Record } from 'immutable';

import { groupBy, minBy } from 'lodash';

import { getStatusContent } from './status_content';

// About two lines on desktop
const VISIBLE_HASHTAGS = 7;

// Those types are not correct, they need to be replaced once this part of the state is typed
type TagLike = Record<{ name: string }>;
type StatusLike = Record<{ tags: List<TagLike> }>;

function normalizeHashtag(hashtag: string) {
  if (hashtag.startsWith('#')) return hashtag.slice(1);
  else return hashtag;
}

function isNodeLinkHashtag(element: Node): element is HTMLLinkElement {
  // it may be a <a> with a hashtag
  return (
    element instanceof HTMLAnchorElement &&
    (element.textContent?.[0] === '#' ||
      element.previousSibling?.textContent?.[
        element.previousSibling.textContent.length - 1
      ] === '#')
  );
}

/**
 * Removes duplicates from an hashtag list, case-insensitive, keeping only the best one
 * "Best" here is defined by the one with the more casing difference (ie, the most camel-cased one)
 * @param hashtags The list of hashtags
 * @returns The input hashtags, but with only 1 occurence of each (case-insensitive)
 */
function uniqueHashtagsWithCaseHandling(hashtags: string[]) {
  const groups = groupBy(hashtags, (tag) => tag.toLowerCase());

  return Object.values(groups).map((tags) => {
    if (tags.length === 1) return tags[0];

    // The best match is the one where we have the less difference between upper and lower case letter count
    const best = minBy(tags, (tag) => {
      const upperCase = Array.from(tag).reduce(
        (acc, char) => (acc += char.toUpperCase() === char ? 1 : 0),
        0,
      );

      const lowerCase = tag.length - upperCase;

      return Math.abs(lowerCase - upperCase);
    });

    return best ?? tags[0];
  });
}

/**
 *  This function will process a status to, at the same time (avoiding parsing it twice):
 * - build the HashtagBar for this status
 * - remove the last-line hashtags from the status content
 * @param status The status to process
 * @returns Props to be passed to the <StatusContent> component, and the hashtagBar to render
 */
export function getHashtagBarForStatus(status: StatusLike): {
  statusContentProps: { statusContent: string };
  hashtagBar: React.ReactNode;
} {
  let statusContent = getStatusContent(status);

  const tagNames = status
    .get('tags')
    .map((tag) => tag.get('name'))
    .toJS();

  // this is returned if we stop the processing early, it does not change what is displayed
  const defaultResult = {
    statusContentProps: { statusContent },
    hashtagBar: null,
  };

  // return early if this status does not have any tags
  if (tagNames.length === 0) return defaultResult;

  const template = document.createElement('template');
  template.innerHTML = statusContent.trim();

  const lastChild = template.content.lastChild;

  if (!lastChild) return defaultResult;

  template.content.removeChild(lastChild);
  const contentWithoutLastLine = template;

  // First, try to parse
  const contentHashtags = Array.from(
    contentWithoutLastLine.content.querySelectorAll<HTMLLinkElement>('a[href]'),
  ).reduce<string[]>((result, link) => {
    if (isNodeLinkHashtag(link)) {
      if (link.textContent) result.push(normalizeHashtag(link.textContent));
    }
    return result;
  }, []);

  const lowercaseContentHashtags = contentHashtags.map((h) => h.toLowerCase());

  // Now we parse the last line, and try to see if it only contains hashtags
  const lastLineHashtags: string[] = [];
  // try to see if the last line is only hashtags
  const onlyHashtags = Array.from(lastChild.childNodes).every((node) => {
    if (isNodeLinkHashtag(node)) {
      const normalized = normalizeHashtag(node.innerText);
      const normalizedLower = normalized.toLowerCase();

      if (!tagNames.includes(normalizedLower))
        // stop here, this is not a real hashtag, so consider it as text
        return false;

      if (!lowercaseContentHashtags.includes(normalizedLower))
        // only add it if it does not appear in the rest of the content
        lastLineHashtags.push(normalized);

      return true;
    } else if (node.nodeType === Node.TEXT_NODE && !node.nodeValue?.trim()) {
      // This is a space
      return true;
    } else return false;
  });

  const lowercaseLastLineHashtags = lastLineHashtags.map((h) =>
    h.toLowerCase(),
  );

  const hashtagsInBar = tagNames.filter(
    (tag) =>
      // the tag does not appear at all in the status content, it is an out-of-band tag
      !lowercaseContentHashtags.includes(tag) &&
      !lowercaseLastLineHashtags.includes(tag),
  );

  if (onlyHashtags) {
    statusContent = contentWithoutLastLine.innerHTML;
    // and add the tags to the bar
    hashtagsInBar.push(...lastLineHashtags);
  }

  return {
    statusContentProps: { statusContent },
    hashtagBar: (
      <HashtagBar hashtags={uniqueHashtagsWithCaseHandling(hashtagsInBar)} />
    ),
  };
}

const HashtagBar: React.FC<{
  hashtags: string[];
}> = ({ hashtags }) => {
  const [expanded, setExpanded] = useState(false);
  const handleClick = useCallback(() => {
    setExpanded(true);
  }, []);

  if (hashtags.length === 0) {
    return null;
  }

  const revealedHashtags = expanded
    ? hashtags
    : hashtags.slice(0, VISIBLE_HASHTAGS - 1);

  return (
    <div className='hashtag-bar'>
      {revealedHashtags.map((hashtag) => (
        <Link key={hashtag} to={`/tags/${hashtag}`}>
          #{hashtag}
        </Link>
      ))}

      {!expanded && hashtags.length > VISIBLE_HASHTAGS && (
        <button className='link-button' onClick={handleClick}>
          <FormattedMessage
            id='hashtags.and_other'
            defaultMessage='…and {count, plural, other {# more}}'
            values={{ count: hashtags.length - VISIBLE_HASHTAGS }}
          />
        </button>
      )}
    </div>
  );
};
