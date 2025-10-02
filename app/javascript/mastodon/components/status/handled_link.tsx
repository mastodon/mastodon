import { useId } from 'react';
import type { ComponentProps, FC } from 'react';

import { Link } from 'react-router-dom';

interface HandledLinkProps {
  href: string;
  text: string;
  hashtagAccountId?: string;
  mentionAccountId?: string;
}

export const HandledLink: FC<HandledLinkProps & ComponentProps<'a'>> = ({
  href,
  text,
  hashtagAccountId,
  mentionAccountId,
  ...props
}) => {
  const id = useId();
  // Handle hashtags
  if (text.startsWith('#')) {
    const hashtag = text.slice(1).trim();
    return (
      <Link
        {...props}
        className='mention hashtag'
        to={`/tags/${hashtag}`}
        rel='tag'
        data-menu-hashtag={hashtagAccountId}
        key={id}
      >
        #<span>{hashtag}</span>
      </Link>
    );
  } else if (text.startsWith('@')) {
    // Handle mentions
    const mention = text.slice(1).trim();
    return (
      <Link
        {...props}
        to={`/@${mention}`}
        title={`@${mention}`}
        data-hover-card-account={mentionAccountId}
        key={id}
      >
        @<span>{mention}</span>
      </Link>
    );
  }
  if (href.startsWith('/')) {
    return text;
  }
  try {
    const url = new URL(href);
    return (
      <a
        {...props}
        href={href}
        title={href}
        className='unhandled-link'
        target='_blank'
        rel='noreferrer noopener'
        translate='no'
        key={id}
      >
        <span className='invisible'>{url.protocol}</span>
        <span className='ellipsis'>
          {url.hostname + url.pathname.split('/').slice(0, 1).join('/')}
        </span>
        <span className='invisible'>
          {url.pathname.split('/').slice(1).join('/') + url.search + url.hash}
        </span>
      </a>
    );
  } catch {
    return text;
  }
};
