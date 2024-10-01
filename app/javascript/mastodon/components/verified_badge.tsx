import CheckIcon from '@/material-icons/400-24px/check.svg?react';

import { Icon } from './icon';

const domParser = new DOMParser();

const stripRelMe = (html: string) => {
  const document = domParser.parseFromString(html, 'text/html').documentElement;

  document.querySelectorAll<HTMLAnchorElement>('a[rel]').forEach((link) => {
    link.rel = link.rel
      .split(' ')
      .filter((x: string) => x !== 'me')
      .join(' ');
  });

  const body = document.querySelector('body');
  return body ? { __html: body.innerHTML } : undefined;
};

interface Props {
  link: string;
}
export const VerifiedBadge: React.FC<Props> = ({ link }) => (
  <span className='verified-badge'>
    <Icon id='check' icon={CheckIcon} className='verified-badge__mark' />
    <span dangerouslySetInnerHTML={stripRelMe(link)} />
  </span>
);
