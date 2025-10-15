import { EmojiHTML } from '@/mastodon/components/emoji/html';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';

import { isModernEmojiEnabled } from '../utils/environment';
import type { OnAttributeHandler } from '../utils/html';

import { Icon } from './icon';

const domParser = new DOMParser();

const stripRelMe = (html: string) => {
  if (isModernEmojiEnabled()) {
    return html;
  }
  const document = domParser.parseFromString(html, 'text/html').documentElement;

  document.querySelectorAll<HTMLAnchorElement>('a[rel]').forEach((link) => {
    link.rel = link.rel
      .split(' ')
      .filter((x: string) => x !== 'me')
      .join(' ');
  });

  const body = document.querySelector('body');
  return body?.innerHTML ?? '';
};

const onAttribute: OnAttributeHandler = (name, value, tagName) => {
  if (name === 'rel' && tagName === 'a') {
    if (value === 'me') {
      return null;
    }
    return [
      name,
      value
        .split(' ')
        .filter((x) => x !== 'me')
        .join(' '),
    ];
  }
  return undefined;
};

interface Props {
  link: string;
}
export const VerifiedBadge: React.FC<Props> = ({ link }) => (
  <span className='verified-badge'>
    <Icon id='check' icon={CheckIcon} className='verified-badge__mark' />
    <EmojiHTML
      as='span'
      htmlString={stripRelMe(link)}
      onAttribute={onAttribute}
    />
  </span>
);
